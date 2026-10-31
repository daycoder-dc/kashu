import '../../../../core/database/daos/transaction_dao.dart';
import '../../../../core/enums/transaction_type.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionModel {
  static TransactionEntity fromDrift(TransactionWithCategory row) {
    final t = row.transaction;
    final c = row.category;
    return TransactionEntity(
      id: t.id,
      concept: t.concept,
      amount: t.amount,
      type: TransactionType.fromValue(t.type),
      isPaid: t.isPaid,
      imagePath: t.imagePath,
      date: t.date,
      categoryId: t.categoryId,
      categoryName: c.name,
      categoryColor: c.color,
      createdAt: t.createdAt,
      updatedAt: t.updatedAt,
    );
  }
}
