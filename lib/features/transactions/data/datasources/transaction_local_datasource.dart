import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/category_dao.dart';
import '../../../../core/database/daos/transaction_dao.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionLocalDatasource {
  final TransactionDao _transactionDao;
  final CategoryDao _categoryDao;

  TransactionLocalDatasource({
    required TransactionDao transactionDao,
    required CategoryDao categoryDao,
  })  : _transactionDao = transactionDao,
        _categoryDao = categoryDao;

  Stream<List<TransactionWithCategory>> watchByMonth(int month, int year) {
    return _transactionDao.watchByMonth(month, year);
  }

  Future<int> create(TransactionEntity entity) {
    return _transactionDao.insertTransaction(
      TransactionItemsCompanion.insert(
        concept: entity.concept,
        amount: entity.amount,
        type: entity.type.value,
        date: entity.date,
        categoryId: entity.categoryId,
        isPaid: Value(entity.isPaid),
        imagePath: Value(entity.imagePath),
      ),
    );
  }

  Future<bool> update(TransactionEntity entity) {
    return _transactionDao.updateTransaction(
      TransactionItemsCompanion(
        id: Value(entity.id),
        concept: Value(entity.concept),
        amount: Value(entity.amount),
        type: Value(entity.type.value),
        date: Value(entity.date),
        categoryId: Value(entity.categoryId),
        isPaid: Value(entity.isPaid),
        imagePath: Value(entity.imagePath),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> delete(int id) => _transactionDao.deleteTransaction(id);

  Future<int> togglePaid(int id, bool isPaid) =>
      _transactionDao.togglePaid(id, isPaid);

  Future<List<Category>> getCategoriesByType(int type) =>
      _categoryDao.getAllByType(type);
}
