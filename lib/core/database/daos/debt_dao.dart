import 'dart:math';

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categories_table.dart';
import '../tables/debt_payments_table.dart';
import '../tables/debts_table.dart';

part 'debt_dao.g.dart';

class DebtWithCategory {
  final Debt debt;
  final Category category;
  final int paidInstallments;

  DebtWithCategory({
    required this.debt,
    required this.category,
    required this.paidInstallments,
  });
}

class DebtPaymentWithInfo {
  final DebtPayment payment;
  final Debt debt;
  final Category category;

  DebtPaymentWithInfo({
    required this.payment,
    required this.debt,
    required this.category,
  });
}

@DriftAccessor(tables: [Debts, DebtPayments, Categories])
class DebtDao extends DatabaseAccessor<AppDatabase> with _$DebtDaoMixin {
  DebtDao(super.db);

  Future<List<DebtWithCategory>> getActiveDebts() async {
    final query = select(debts).join([
      innerJoin(categories, categories.id.equalsExp(debts.categoryId)),
    ])
      ..where(debts.isActive.equals(true))
      ..orderBy([OrderingTerm.asc(debts.name)]);

    final rows = await query.get();
    final results = <DebtWithCategory>[];

    for (final row in rows) {
      final debt = row.readTable(debts);
      final category = row.readTable(categories);
      final paidCount = await _paidCount(debt.id);
      results.add(DebtWithCategory(
        debt: debt,
        category: category,
        paidInstallments: paidCount,
      ));
    }
    return results;
  }

  Future<int> _paidCount(int debtId) async {
    final count = debtPayments.id.count();
    final q = selectOnly(debtPayments)
      ..addColumns([count])
      ..where(
          debtPayments.debtId.equals(debtId) & debtPayments.isPaid.equals(true));
    final result = await q.getSingle();
    return result.read(count) ?? 0;
  }

  Future<Debt?> getDebtById(int id) {
    return (select(debts)..where((d) => d.id.equals(id))).getSingleOrNull();
  }

  Future<List<DebtPayment>> getPaymentsForDebt(int debtId) {
    return (select(debtPayments)
          ..where((p) => p.debtId.equals(debtId))
          ..orderBy([(p) => OrderingTerm.asc(p.installmentNumber)]))
        .get();
  }

  Future<int> insertDebt(DebtsCompanion entry) async {
    final debtId = await into(debts).insert(entry);
    await _generatePayments(debtId, entry);
    return debtId;
  }

  Future<void> _generatePayments(int debtId, DebtsCompanion entry) async {
    final startDate = entry.startDate.value;
    final totalInstallments = entry.totalInstallments.value;
    final monthlyPayment = entry.monthlyPayment.value;

    await batch((b) {
      final companions = List.generate(totalInstallments, (i) {
        final payDate = DateTime(startDate.year, startDate.month + i, 1);
        return DebtPaymentsCompanion.insert(
          debtId: debtId,
          installmentNumber: i + 1,
          month: payDate.month,
          year: payDate.year,
          amount: monthlyPayment,
        );
      });
      b.insertAll(debtPayments, companions);
    });
  }

  Future<bool> updateDebt(DebtsCompanion entry) {
    return update(debts).replace(entry);
  }

  Future<void> deleteDebt(int id) async {
    await (delete(debtPayments)..where((p) => p.debtId.equals(id))).go();
    await (delete(debts)..where((d) => d.id.equals(id))).go();
  }

  Future<void> togglePayment(int paymentId, bool isPaid) async {
    await (update(debtPayments)..where((p) => p.id.equals(paymentId))).write(
      DebtPaymentsCompanion(
        isPaid: Value(isPaid),
        paidAt: Value(isPaid ? DateTime.now() : null),
      ),
    );
  }

  Future<double> totalActiveDebt() async {
    final sum = debts.totalAmount.sum();
    final query = selectOnly(debts)
      ..addColumns([sum])
      ..where(debts.isActive.equals(true));
    final result = await query.getSingle();
    return result.read(sum) ?? 0.0;
  }

  Future<double> totalMonthlyPayments() async {
    final sum = debts.monthlyPayment.sum();
    final query = selectOnly(debts)
      ..addColumns([sum])
      ..where(debts.isActive.equals(true));
    final result = await query.getSingle();
    return result.read(sum) ?? 0.0;
  }

  Future<double> totalPaidAmount() async {
    final sum = debtPayments.amount.sum();
    final query = select(debtPayments).join([
      innerJoin(debts, debts.id.equalsExp(debtPayments.debtId)),
    ]);
    query
      ..addColumns([sum])
      ..where(debtPayments.isPaid.equals(true) & debts.isActive.equals(true));
    final rows = await query.get();
    if (rows.isEmpty) return 0.0;
    return rows.first.read(sum) ?? 0.0;
  }

  Future<double> sumPaidPayments(int month, int year) async {
    final sum = debtPayments.amount.sum();
    final query = selectOnly(debtPayments)
      ..addColumns([sum])
      ..where(debtPayments.isPaid.equals(true) &
          debtPayments.month.equals(month) &
          debtPayments.year.equals(year));
    final result = await query.getSingle();
    return result.read(sum) ?? 0.0;
  }

  Future<double> sumDuePayments(int month, int year) async {
    final sum = debtPayments.amount.sum();
    final query = selectOnly(debtPayments)
      ..addColumns([sum])
      ..where(debtPayments.month.equals(month) &
          debtPayments.year.equals(year));
    final result = await query.getSingle();
    return result.read(sum) ?? 0.0;
  }

  Future<List<DebtPaymentWithInfo>> getPaymentsForMonth(
      int month, int year) async {
    final query = select(debtPayments).join([
      innerJoin(debts, debts.id.equalsExp(debtPayments.debtId)),
      innerJoin(categories, categories.id.equalsExp(debts.categoryId)),
    ])
      ..where(debtPayments.month.equals(month) &
          debtPayments.year.equals(year) &
          debts.isActive.equals(true));

    final rows = await query.get();
    return rows
        .map((row) => DebtPaymentWithInfo(
              payment: row.readTable(debtPayments),
              debt: row.readTable(debts),
              category: row.readTable(categories),
            ))
        .toList();
  }

  static double calculateMonthlyPayment(
      double principal, double annualRate, int installments) {
    if (annualRate <= 0) return principal / installments;
    final r = annualRate / 100 / 12;
    final factor = pow(1 + r, installments);
    return principal * (r * factor) / (factor - 1);
  }
}
