import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/fixed_expense_dao.dart';
import '../../../../core/database/daos/transaction_dao.dart';

class FixedExpenseLocalDatasource {
  final FixedExpenseDao _fixedExpenseDao;
  final TransactionDao _transactionDao;

  FixedExpenseLocalDatasource({
    required FixedExpenseDao fixedExpenseDao,
    required TransactionDao transactionDao,
  })  : _fixedExpenseDao = fixedExpenseDao,
        _transactionDao = transactionDao;

  Stream<List<FixedExpenseWithCategory>> watchActiveWithPayments(
      int month, int year) {
    return _fixedExpenseDao.watchActiveWithPayments(month, year);
  }

  Future<List<FixedExpenseWithCategory>> getActiveWithPayments(
      int month, int year) {
    return _fixedExpenseDao.getActiveWithPayments(month, year);
  }

  Future<int> insertFixedExpense(
      String name, double amount, int categoryId) {
    return _fixedExpenseDao.insertFixedExpense(
      FixedExpensesCompanion.insert(
        name: name,
        amount: amount,
        categoryId: categoryId,
      ),
    );
  }

  Future<void> updateFixedExpense(
      int id, String name, double amount, int categoryId) {
    return _fixedExpenseDao.updateFixedExpense(
      FixedExpensesCompanion(
        id: Value(id),
        name: Value(name),
        amount: Value(amount),
        categoryId: Value(categoryId),
      ),
    );
  }

  Future<int> deleteFixedExpense(int id) {
    return _fixedExpenseDao.deleteFixedExpense(id);
  }

  Future<void> togglePayment(
      int fixedExpenseId, int month, int year, bool isPaid) {
    return _fixedExpenseDao.togglePayment(
        fixedExpenseId, month, year, isPaid);
  }

  Future<double> sumActiveExpenses() {
    return _fixedExpenseDao.sumActiveExpenses();
  }

  Future<double> sumPaidExpenses(int month, int year) {
    return _fixedExpenseDao.sumPaidExpenses(month, year);
  }

  Future<double> getTotalIncome(int month, int year) =>
      _transactionDao.sumByTypeAndMonth(1, month, year);
}
