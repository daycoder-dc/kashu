import '../../../../core/database/daos/monthly_budget_dao.dart';
import '../../../../core/database/daos/transaction_dao.dart';

class DashboardLocalDatasource {
  final TransactionDao _transactionDao;
  final MonthlyBudgetDao _budgetDao;

  DashboardLocalDatasource({
    required TransactionDao transactionDao,
    required MonthlyBudgetDao budgetDao,
  })  : _transactionDao = transactionDao,
        _budgetDao = budgetDao;

  Future<double> getTotalExpenses(int month, int year) =>
      _transactionDao.sumByTypeAndMonth(0, month, year);

  Future<double> getTotalIncome(int month, int year) =>
      _transactionDao.sumByTypeAndMonth(1, month, year);

  Future<double> getTotalPaidExpenses(int month, int year) =>
      _transactionDao.sumPaidExpensesByMonth(month, year);

  Future<double?> getBudgetAmount(int month, int year) async {
    final budget = await _budgetDao.getByMonthYear(month, year);
    return budget?.budgetAmount;
  }

  Stream<List<TransactionWithCategory>> watchTransactions(int month, int year) {
    return _transactionDao.watchByMonth(month, year);
  }
}
