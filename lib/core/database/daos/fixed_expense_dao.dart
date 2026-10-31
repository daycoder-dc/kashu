import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categories_table.dart';
import '../tables/fixed_expense_payments_table.dart';
import '../tables/fixed_expenses_table.dart';

part 'fixed_expense_dao.g.dart';

class FixedExpenseWithCategory {
  final FixedExpense fixedExpense;
  final Category category;
  final FixedExpensePayment? payment;

  FixedExpenseWithCategory({
    required this.fixedExpense,
    required this.category,
    this.payment,
  });

  bool get isPaid => payment?.isPaid ?? false;
}

@DriftAccessor(tables: [FixedExpenses, FixedExpensePayments, Categories])
class FixedExpenseDao extends DatabaseAccessor<AppDatabase>
    with _$FixedExpenseDaoMixin {
  FixedExpenseDao(super.db);

  Future<List<FixedExpenseWithCategory>> getActiveWithPayments(
      int month, int year) async {
    final query = select(fixedExpenses).join([
      innerJoin(
        categories,
        categories.id.equalsExp(fixedExpenses.categoryId),
      ),
      leftOuterJoin(
        fixedExpensePayments,
        fixedExpensePayments.fixedExpenseId.equalsExp(fixedExpenses.id) &
            fixedExpensePayments.month.equals(month) &
            fixedExpensePayments.year.equals(year),
      ),
    ])
      ..where(fixedExpenses.isActive.equals(true))
      ..orderBy([OrderingTerm.asc(fixedExpenses.name)]);

    final rows = await query.get();
    return rows.map((row) {
      return FixedExpenseWithCategory(
        fixedExpense: row.readTable(fixedExpenses),
        category: row.readTable(categories),
        payment: row.readTableOrNull(fixedExpensePayments),
      );
    }).toList();
  }

  Stream<List<FixedExpenseWithCategory>> watchActiveWithPayments(
      int month, int year) {
    final query = select(fixedExpenses).join([
      innerJoin(
        categories,
        categories.id.equalsExp(fixedExpenses.categoryId),
      ),
      leftOuterJoin(
        fixedExpensePayments,
        fixedExpensePayments.fixedExpenseId.equalsExp(fixedExpenses.id) &
            fixedExpensePayments.month.equals(month) &
            fixedExpensePayments.year.equals(year),
      ),
    ])
      ..where(fixedExpenses.isActive.equals(true))
      ..orderBy([OrderingTerm.asc(fixedExpenses.name)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return FixedExpenseWithCategory(
          fixedExpense: row.readTable(fixedExpenses),
          category: row.readTable(categories),
          payment: row.readTableOrNull(fixedExpensePayments),
        );
      }).toList();
    });
  }

  Future<int> insertFixedExpense(FixedExpensesCompanion entry) {
    return into(fixedExpenses).insert(entry);
  }

  Future<bool> updateFixedExpense(FixedExpensesCompanion entry) {
    return update(fixedExpenses).replace(entry);
  }

  Future<int> deleteFixedExpense(int id) {
    return (delete(fixedExpenses)..where((t) => t.id.equals(id))).go();
  }

  Future<void> togglePayment(int fixedExpenseId, int month, int year,
      bool isPaid) async {
    final existing = await (select(fixedExpensePayments)
          ..where((p) =>
              p.fixedExpenseId.equals(fixedExpenseId) &
              p.month.equals(month) &
              p.year.equals(year)))
        .getSingleOrNull();

    if (existing != null) {
      await (update(fixedExpensePayments)
            ..where((p) => p.id.equals(existing.id)))
          .write(FixedExpensePaymentsCompanion(
        isPaid: Value(isPaid),
        paidAt: Value(isPaid ? DateTime.now() : null),
      ));
    } else {
      await into(fixedExpensePayments).insert(
        FixedExpensePaymentsCompanion.insert(
          fixedExpenseId: fixedExpenseId,
          month: month,
          year: year,
          isPaid: Value(isPaid),
          paidAt: Value(isPaid ? DateTime.now() : null),
        ),
      );
    }
  }

  Future<double> sumActiveExpenses() async {
    final sum = fixedExpenses.amount.sum();
    final query = selectOnly(fixedExpenses)
      ..addColumns([sum])
      ..where(fixedExpenses.isActive.equals(true));
    final result = await query.getSingle();
    return result.read(sum) ?? 0.0;
  }

  Future<double> sumPaidExpenses(int month, int year) async {
    final query = select(fixedExpenses).join([
      innerJoin(
        fixedExpensePayments,
        fixedExpensePayments.fixedExpenseId.equalsExp(fixedExpenses.id) &
            fixedExpensePayments.month.equals(month) &
            fixedExpensePayments.year.equals(year) &
            fixedExpensePayments.isPaid.equals(true),
      ),
    ])
      ..where(fixedExpenses.isActive.equals(true));

    final rows = await query.get();
    return rows.fold<double>(
        0.0, (acc, row) => acc + row.readTable(fixedExpenses).amount);
  }
}
