import '../../../../core/error/either_typedefs.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransaction {
  final TransactionRepository _repository;

  DeleteTransaction(this._repository);

  FutureEither<void> call(int id) {
    return _repository.delete(id);
  }
}
