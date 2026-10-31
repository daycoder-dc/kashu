import '../entities/monthly_summary.dart';
import '../repositories/dashboard_repository.dart';

class GetMonthlySummary {
  final DashboardRepository _repository;

  GetMonthlySummary(this._repository);

  Stream<MonthlySummary> call(int month, int year) {
    return _repository.watchMonthlySummary(month, year);
  }
}
