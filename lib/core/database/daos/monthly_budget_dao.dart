import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/monthly_budgets_table.dart';

part 'monthly_budget_dao.g.dart';

@DriftAccessor(tables: [MonthlyBudgets])
class MonthlyBudgetDao extends DatabaseAccessor<AppDatabase>
    with _$MonthlyBudgetDaoMixin {
  MonthlyBudgetDao(super.db);

  Future<MonthlyBudget?> getByMonthYear(int month, int year) {
    return (select(monthlyBudgets)
          ..where(
              (b) => b.month.equals(month) & b.year.equals(year)))
        .getSingleOrNull();
  }

  Future<int> upsert(MonthlyBudgetsCompanion entry) {
    return into(monthlyBudgets).insert(
      entry,
      onConflict: DoUpdate(
        (old) => MonthlyBudgetsCompanion(
          budgetAmount: entry.budgetAmount,
          updatedAt: Value(DateTime.now()),
        ),
        target: [monthlyBudgets.month, monthlyBudgets.year],
      ),
    );
  }

  Future<int> deleteBudget(int id) {
    return (delete(monthlyBudgets)..where((b) => b.id.equals(id))).go();
  }

  Stream<MonthlyBudget?> watchByMonthYear(int month, int year) {
    return (select(monthlyBudgets)
          ..where(
              (b) => b.month.equals(month) & b.year.equals(year)))
        .watchSingleOrNull();
  }
}
