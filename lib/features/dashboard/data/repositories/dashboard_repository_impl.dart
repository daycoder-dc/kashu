import 'package:fpdart/fpdart.dart';

import '../../../../core/error/either_typedefs.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/monthly_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDatasource _datasource;

  DashboardRepositoryImpl({required DashboardLocalDatasource datasource})
      : _datasource = datasource;

  @override
  FutureEither<MonthlySummary> getMonthlySummary(int month, int year) async {
    try {
      final expenses = await _datasource.getTotalExpenses(month, year);
      final income = await _datasource.getTotalIncome(month, year);
      final paidExpenses = await _datasource.getTotalPaidExpenses(month, year);
      final budget = await _datasource.getBudgetAmount(month, year);

      return Right(MonthlySummary(
        month: month,
        year: year,
        totalIncome: income,
        totalExpenses: expenses,
        totalPaidExpenses: paidExpenses,
        budgetAmount: budget,
      ));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Stream<MonthlySummary> watchMonthlySummary(int month, int year) {
    return _datasource.watchTransactions(month, year).asyncMap((_) async {
      final result = await getMonthlySummary(month, year);
      return result.getOrElse(
        (_) => MonthlySummary(
          month: month,
          year: year,
          totalIncome: 0,
          totalExpenses: 0,
          totalPaidExpenses: 0,
        ),
      );
    });
  }
}
