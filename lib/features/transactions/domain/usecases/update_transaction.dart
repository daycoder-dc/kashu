import '../../../../core/error/either_typedefs.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransaction {
  final TransactionRepository _repository;

  UpdateTransaction(this._repository);

  FutureEither<void> call(TransactionEntity entity) {
    return _repository.update(entity);
  }
}
