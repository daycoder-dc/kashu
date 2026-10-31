import '../../../../core/error/either_typedefs.dart';
import '../entities/monthly_summary.dart';

abstract class DashboardRepository {
  FutureEither<MonthlySummary> getMonthlySummary(int month, int year);
  Stream<MonthlySummary> watchMonthlySummary(int month, int year);
}
