import '../../../../core/database/daos/fixed_expense_dao.dart';
import '../../../../core/database/daos/debt_dao.dart';
import '../../../../core/database/daos/transaction_dao.dart';

class StatisticsLocalDatasource {
  final TransactionDao _transactionDao;
  final FixedExpenseDao _fixedExpenseDao;
  final DebtDao _debtDao;

  StatisticsLocalDatasource({
    required TransactionDao transactionDao,
    required FixedExpenseDao fixedExpenseDao,
    required DebtDao debtDao,
  })  : _transactionDao = transactionDao,
        _fixedExpenseDao = fixedExpenseDao,
        _debtDao = debtDao;

  Stream<List<TransactionWithCategory>> watchExpensesByMonth(
      int month, int year) {
    return _transactionDao.watchByMonth(month, year);
  }

  Future<List<FixedExpenseWithCategory>> getFixedExpenses(
      int month, int year) {
    return _fixedExpenseDao.getActiveWithPayments(month, year);
  }

  Future<List<DebtWithCategory>> getActiveDebts() {
    return _debtDao.getActiveDebts();
  }
}
