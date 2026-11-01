import 'package:fpdart/fpdart.dart';

import '../../../../core/database/daos/debt_dao.dart';
import '../../../../core/database/daos/fixed_expense_dao.dart';
import '../../../../core/database/daos/transaction_dao.dart';
import '../../../../core/error/either_typedefs.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category_stat.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/statistics_local_datasource.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsLocalDatasource _datasource;

  StatisticsRepositoryImpl({required StatisticsLocalDatasource datasource})
      : _datasource = datasource;

  @override
  FutureEither<List<CategoryStat>> getCategoryBreakdown(
      int month, int year) async {
    try {
      final results = await Future.wait([
        _datasource.watchExpensesByMonth(month, year).first,
        _datasource.getFixedExpenses(month, year),
        _datasource.getActiveDebts(),
      ]);

      final rows = results[0] as List<TransactionWithCategory>;
      final fixedExpenses = results[1] as List<FixedExpenseWithCategory>;
      final debts = results[2] as List<DebtWithCategory>;

      final Map<String, _Accumulator> grouped = {};
      double total = 0;

      for (final row in rows) {
        if (row.transaction.type == 0) {
          final name = row.category.name;
          grouped.putIfAbsent(
              name, () => _Accumulator(color: row.category.color));
          grouped[name]!.amount += row.transaction.amount;
          total += row.transaction.amount;
        }
      }

      for (final fe in fixedExpenses) {
        final name = fe.category.name;
        grouped.putIfAbsent(
            name, () => _Accumulator(color: fe.category.color));
        grouped[name]!.amount += fe.fixedExpense.amount;
        total += fe.fixedExpense.amount;
      }

      for (final d in debts) {
        final name = d.category.name;
        grouped.putIfAbsent(
            name, () => _Accumulator(color: d.category.color));
        grouped[name]!.amount += d.debt.monthlyPayment;
        total += d.debt.monthlyPayment;
      }

      final stats = grouped.entries
          .map((e) => CategoryStat(
                categoryName: e.key,
                categoryColor: e.value.color,
                totalAmount: e.value.amount,
                percentage: total > 0 ? (e.value.amount / total) * 100 : 0,
              ))
          .toList()
        ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

      return Right(stats);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}

class _Accumulator {
  final int color;
  double amount = 0;
  _Accumulator({required this.color});
}
