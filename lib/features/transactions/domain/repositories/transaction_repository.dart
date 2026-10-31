import '../../../../core/error/either_typedefs.dart';
import '../entities/category_entity.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Stream<List<TransactionEntity>> watchByMonth(int month, int year);
  FutureEither<int> create(TransactionEntity entity);
  FutureEither<void> update(TransactionEntity entity);
  FutureEither<void> delete(int id);
  FutureEither<void> togglePaid(int id, bool isPaid);
  FutureEither<List<CategoryEntity>> getCategories(int type);
}
