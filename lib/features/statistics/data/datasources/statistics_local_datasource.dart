import '../../../../core/database/daos/transaction_dao.dart';

class StatisticsLocalDatasource {
  final TransactionDao _transactionDao;

  StatisticsLocalDatasource({required TransactionDao transactionDao})
      : _transactionDao = transactionDao;

  Stream<List<TransactionWithCategory>> watchExpensesByMonth(
      int month, int year) {
    return _transactionDao.watchByMonth(month, year);
  }
}
