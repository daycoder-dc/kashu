import 'package:fpdart/fpdart.dart';

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
      final rows =
          await _datasource.watchExpensesByMonth(month, year).first;

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
