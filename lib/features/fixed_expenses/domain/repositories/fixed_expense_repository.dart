import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/fixed_expense_entity.dart';
import '../entities/fixed_expenses_summary.dart';

abstract class FixedExpenseRepository {
  Future<Either<Failure, FixedExpensesSummary>> getSummary(
      int month, int year);

  Stream<Either<Failure, List<FixedExpenseEntity>>> watchExpenses(
      int month, int year);

  Future<Either<Failure, int>> createFixedExpense({
    required String name,
    required double amount,
    required int categoryId,
  });

  Future<Either<Failure, void>> updateFixedExpense({
    required int id,
    required String name,
    required double amount,
    required int categoryId,
  });

  Future<Either<Failure, void>> deleteFixedExpense(int id);

  Future<Either<Failure, void>> togglePayment({
    required int fixedExpenseId,
    required int month,
    required int year,
    required bool isPaid,
  });
}
