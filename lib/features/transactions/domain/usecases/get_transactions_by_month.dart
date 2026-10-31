import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsByMonth {
  final TransactionRepository _repository;

  GetTransactionsByMonth(this._repository);

  Stream<List<TransactionEntity>> call(int month, int year) {
    return _repository.watchByMonth(month, year);
  }
}
