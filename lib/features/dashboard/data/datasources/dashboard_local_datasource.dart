import '../../../../core/database/daos/debt_dao.dart';
import '../../../../core/database/daos/fixed_expense_dao.dart';
import '../../../../core/database/daos/monthly_budget_dao.dart';
import '../../../../core/database/daos/transaction_dao.dart';

class DashboardLocalDatasource {
  final TransactionDao _transactionDao;
  final MonthlyBudgetDao _budgetDao;
  final FixedExpenseDao _fixedExpenseDao;
  final DebtDao _debtDao;

  DashboardLocalDatasource({
    required TransactionDao transactionDao,
    required MonthlyBudgetDao budgetDao,
    required FixedExpenseDao fixedExpenseDao,
    required DebtDao debtDao,
  })  : _transactionDao = transactionDao,
        _budgetDao = budgetDao,
        _fixedExpenseDao = fixedExpenseDao,
        _debtDao = debtDao;

  Future<double> getTotalExpenses(int month, int year) =>
      _transactionDao.sumByTypeAndMonth(0, month, year);

  Future<double> getTotalIncome(int month, int year) =>
      _transactionDao.sumByTypeAndMonth(1, month, year);

  Future<double> getTotalPaidExpenses(int month, int year) =>
      _transactionDao.sumPaidExpensesByMonth(month, year);

  Future<double> getFixedExpensesTotal() =>
      _fixedExpenseDao.sumActiveExpenses();

  Future<double> getFixedExpensesPaid(int month, int year) =>
      _fixedExpenseDao.sumPaidExpenses(month, year);

  Future<double> getDebtPaymentsTotal(int month, int year) =>
      _debtDao.sumDuePayments(month, year);

  Future<double> getDebtPaymentsPaid(int month, int year) =>
      _debtDao.sumPaidPayments(month, year);

  Future<double?> getBudgetAmount(int month, int year) async {
    final budget = await _budgetDao.getByMonthYear(month, year);
    return budget?.budgetAmount;
  }

  Stream<List<TransactionWithCategory>> watchTransactions(int month, int year) {
    return _transactionDao.watchByMonth(month, year);
  }
}
