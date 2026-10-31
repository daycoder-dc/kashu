import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categories_table.dart';
import '../tables/transactions_table.dart';

part 'transaction_dao.g.dart';

class TransactionWithCategory {
  final TransactionItem transaction;
  final Category category;

  TransactionWithCategory({
    required this.transaction,
    required this.category,
  });
}

@DriftAccessor(tables: [TransactionItems, Categories])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  Stream<List<TransactionWithCategory>> watchByMonth(int month, int year) {
    final startDate = DateTime(year, month);
    final endDate = DateTime(year, month + 1);

    final query = select(transactionItems).join([
      innerJoin(
        categories,
        categories.id.equalsExp(transactionItems.categoryId),
      ),
    ])
      ..where(transactionItems.date.isBiggerOrEqualValue(startDate) &
          transactionItems.date.isSmallerThanValue(endDate))
      ..orderBy([OrderingTerm.desc(transactionItems.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          transaction: row.readTable(transactionItems),
          category: row.readTable(categories),
        );
      }).toList();
    });
  }

  Future<int> insertTransaction(TransactionItemsCompanion entry) {
    return into(transactionItems).insert(entry);
  }

  Future<bool> updateTransaction(TransactionItemsCompanion entry) {
    return update(transactionItems).replace(entry);
  }

  Future<int> deleteTransaction(int id) {
    return (delete(transactionItems)..where((t) => t.id.equals(id))).go();
  }

  Future<double> sumByTypeAndMonth(int type, int month, int year) async {
    final startDate = DateTime(year, month);
    final endDate = DateTime(year, month + 1);

    final sum = transactionItems.amount.sum();
    final query = selectOnly(transactionItems)
      ..addColumns([sum])
      ..where(transactionItems.type.equals(type) &
          transactionItems.date.isBiggerOrEqualValue(startDate) &
          transactionItems.date.isSmallerThanValue(endDate));

    final result = await query.getSingle();
    return result.read(sum) ?? 0.0;
  }

  Future<int> togglePaid(int id, bool isPaid) {
    return (update(transactionItems)..where((t) => t.id.equals(id)))
        .write(TransactionItemsCompanion(
      isPaid: Value(isPaid),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<double> sumPaidExpensesByMonth(int month, int year) async {
    final startDate = DateTime(year, month);
    final endDate = DateTime(year, month + 1);

    final sum = transactionItems.amount.sum();
    final query = selectOnly(transactionItems)
      ..addColumns([sum])
      ..where(transactionItems.type.equals(0) &
          transactionItems.isPaid.equals(true) &
          transactionItems.date.isBiggerOrEqualValue(startDate) &
          transactionItems.date.isSmallerThanValue(endDate));

    final result = await query.getSingle();
    return result.read(sum) ?? 0.0;
  }
}
