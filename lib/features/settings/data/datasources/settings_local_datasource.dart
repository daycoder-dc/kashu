import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/monthly_budget_dao.dart';
import '../../../../core/database/daos/settings_dao.dart';

class SettingsLocalDatasource {
  final SettingsDao _settingsDao;
  final MonthlyBudgetDao _budgetDao;

  SettingsLocalDatasource({
    required SettingsDao settingsDao,
    required MonthlyBudgetDao budgetDao,
  })  : _settingsDao = settingsDao,
        _budgetDao = budgetDao;

  Future<String?> getValue(String key) => _settingsDao.getValue(key);

  Future<void> setValue(String key, String value) =>
      _settingsDao.setValue(key, value);

  Future<Map<String, String>> getAll() => _settingsDao.getAll();

  Future<double?> getBudget(int month, int year) async {
    final budget = await _budgetDao.getByMonthYear(month, year);
    return budget?.budgetAmount;
  }

  Future<void> setBudget(int month, int year, double amount) {
    return _budgetDao.upsert(MonthlyBudgetsCompanion(
      month: Value(month),
      year: Value(year),
      budgetAmount: Value(amount),
      updatedAt: Value(DateTime.now()),
    ));
  }
}
