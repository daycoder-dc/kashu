import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/debt_entity.dart';
import '../../domain/entities/debt_payment_entity.dart';
import '../../domain/entities/debts_summary.dart';
import '../../domain/repositories/debt_repository.dart';
import '../datasources/debt_local_datasource.dart';

class DebtRepositoryImpl implements DebtRepository {
  final DebtLocalDatasource _datasource;

  DebtRepositoryImpl({required DebtLocalDatasource datasource})
      : _datasource = datasource;

  @override
  Future<Either<Failure, DebtsSummary>> getSummary() async {
    try {
      final items = await _datasource.getActiveDebts();
      final totalDebt = await _datasource.totalActiveDebt();
      final totalPaid = await _datasource.totalPaidAmount();
      final totalMonthly = await _datasource.totalMonthlyPayments();

      final debts = items
          .map((item) => DebtEntity(
                id: item.debt.id,
                name: item.debt.name,
                totalAmount: item.debt.totalAmount,
                interestRate: item.debt.interestRate,
                totalInstallments: item.debt.totalInstallments,
                paidInstallments: item.paidInstallments,
                monthlyPayment: item.debt.monthlyPayment,
                startDate: item.debt.startDate,
                categoryId: item.category.id,
                categoryName: item.category.name,
                categoryColor: item.category.color,
                categoryIconCodePoint: item.category.iconCodePoint,
                isActive: item.debt.isActive,
              ))
          .toList();

      return Right(DebtsSummary(
        debts: debts,
        totalDebt: totalDebt,
        totalPaid: totalPaid,
        totalRemaining: totalDebt - totalPaid,
        totalMonthlyPayments: totalMonthly,
      ));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DebtEntity>> getDebtById(int id) async {
    try {
      final debt = await _datasource.getDebtById(id);
      if (debt == null) {
        return const Left(DatabaseFailure(message: 'Credito no encontrado'));
      }
      final items = await _datasource.getActiveDebts();
      final item = items.firstWhere((i) => i.debt.id == id);

      return Right(DebtEntity(
        id: item.debt.id,
        name: item.debt.name,
        totalAmount: item.debt.totalAmount,
        interestRate: item.debt.interestRate,
        totalInstallments: item.debt.totalInstallments,
        paidInstallments: item.paidInstallments,
        monthlyPayment: item.debt.monthlyPayment,
        startDate: item.debt.startDate,
        categoryId: item.category.id,
        categoryName: item.category.name,
        categoryColor: item.category.color,
        categoryIconCodePoint: item.category.iconCodePoint,
        isActive: item.debt.isActive,
      ));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DebtPaymentEntity>>> getPayments(
      int debtId) async {
    try {
      final payments = await _datasource.getPaymentsForDebt(debtId);
      return Right(payments
          .map((p) => DebtPaymentEntity(
                id: p.id,
                debtId: p.debtId,
                installmentNumber: p.installmentNumber,
                month: p.month,
                year: p.year,
                amount: p.amount,
                isPaid: p.isPaid,
                paidAt: p.paidAt,
              ))
          .toList());
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> createDebt({
    required String name,
    required double totalAmount,
    required double interestRate,
    required int totalInstallments,
    required double monthlyPayment,
    required DateTime startDate,
    required int categoryId,
  }) async {
    try {
      final id = await _datasource.insertDebt(
        name: name,
        totalAmount: totalAmount,
        interestRate: interestRate,
        totalInstallments: totalInstallments,
        monthlyPayment: monthlyPayment,
        startDate: startDate,
        categoryId: categoryId,
      );
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDebt(int id) async {
    try {
      await _datasource.deleteDebt(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> togglePayment({
    required int paymentId,
    required bool isPaid,
  }) async {
    try {
      await _datasource.togglePayment(paymentId, isPaid);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
