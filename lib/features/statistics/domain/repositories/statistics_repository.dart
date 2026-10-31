import '../../../../core/error/either_typedefs.dart';
import '../entities/category_stat.dart';

abstract class StatisticsRepository {
  FutureEither<List<CategoryStat>> getCategoryBreakdown(int month, int year);
}
