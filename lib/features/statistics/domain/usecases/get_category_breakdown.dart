import '../../../../core/error/either_typedefs.dart';
import '../entities/category_stat.dart';
import '../repositories/statistics_repository.dart';

class GetCategoryBreakdown {
  final StatisticsRepository _repository;

  GetCategoryBreakdown(this._repository);

  FutureEither<List<CategoryStat>> call(int month, int year) {
    return _repository.getCategoryBreakdown(month, year);
  }
}
