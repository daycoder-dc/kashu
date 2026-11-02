import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/fixed_expense_entity.dart';
import '../../domain/entities/fixed_expenses_summary.dart';
import '../../domain/repositories/fixed_expense_repository.dart';
import '../datasources/fixed_expense_local_datasource.dart';

class FixedExpenseRepositoryImpl implements FixedExpenseRepository {
  final FixedExpenseLocalDatasource _datasource;

  FixedExpenseRepositoryImpl({required FixedExpenseLocalDatasource datasource})
      : _datasource = datasource;

  @override
  Future<Either<Failure, FixedExpensesSummary>> getSummary(
      int month, int year) async {
    try {
      final items = await _datasource.getActiveWithPayments(month, year);
      final income = await _datasource.getTotalIncome(month, year);
      final debtPayments =
          await _datasource.getDebtPaymentsForMonth(month, year);

      final expenses = items
          .map((item) => FixedExpenseEntity(
                id: item.fixedExpense.id,
                name: item.fixedExpense.name,
                amount: item.fixedExpense.amount,
                categoryId: item.category.id,
                categoryName: item.category.name,
                categoryColor: item.category.color,
                categoryIconCodePoint: item.category.iconCodePoint,
                isActive: item.fixedExpense.isActive,
                isPaidThisMonth: item.isPaid,
              ))
          .toList();

      final debtExpenses = debtPayments
          .map((dp) => FixedExpenseEntity(
                id: dp.debt.id,
                name: dp.debt.name,
                amount: dp.payment.amount,
                categoryId: dp.category.id,
                categoryName: dp.category.name,
                categoryColor: dp.category.color,
                categoryIconCodePoint: dp.category.iconCodePoint,
                isActive: true,
                isPaidThisMonth: dp.payment.isPaid,
                isDebtPayment: true,
                debtPaymentId: dp.payment.id,
              ))
          .toList();

      final allExpenses = [...expenses, ...debtExpenses];

      final totalExpenses =
          allExpenses.fold<double>(0, (sum, e) => sum + e.amount);
      final totalPaid = allExpenses
          .where((e) => e.isPaidThisMonth)
          .fold<double>(0, (sum, e) => sum + e.amount);

      return Right(FixedExpensesSummary(
        expenses: allExpenses,
        totalExpenses: totalExpenses,
        totalPaid: totalPaid,
        totalRemaining: totalExpenses - totalPaid,
        salary: income,
      ));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<FixedExpenseEntity>>> watchExpenses(
      int month, int year) {
    return _datasource.watchActiveWithPayments(month, year).map((items) {
      try {
        final expenses = items
            .map((item) => FixedExpenseEntity(
                  id: item.fixedExpense.id,
                  name: item.fixedExpense.name,
                  amount: item.fixedExpense.amount,
                  categoryId: item.category.id,
                  categoryName: item.category.name,
                  categoryColor: item.category.color,
                  categoryIconCodePoint: item.category.iconCodePoint,
                  isActive: item.fixedExpense.isActive,
                  isPaidThisMonth: item.isPaid,
                ))
            .toList();
        return Right<Failure, List<FixedExpenseEntity>>(expenses);
      } catch (e) {
        return Left<Failure, List<FixedExpenseEntity>>(
            DatabaseFailure(message: e.toString()));
      }
    });
  }

  @override
  Future<Either<Failure, int>> createFixedExpense({
    required String name,
    required double amount,
    required int categoryId,
  }) async {
    try {
      final id = await _datasource.insertFixedExpense(
          name, amount, categoryId);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateFixedExpense({
    required int id,
    required String name,
    required double amount,
    required int categoryId,
  }) async {
    try {
      await _datasource.updateFixedExpense(id, name, amount, categoryId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFixedExpense(int id) async {
    try {
      await _datasource.deleteFixedExpense(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> togglePayment({
    required int fixedExpenseId,
    required int month,
    required int year,
    required bool isPaid,
  }) async {
    try {
      await _datasource.togglePayment(fixedExpenseId, month, year, isPaid);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleDebtPayment({
    required int debtPaymentId,
    required bool isPaid,
  }) async {
    try {
      await _datasource.toggleDebtPayment(debtPaymentId, isPaid);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
