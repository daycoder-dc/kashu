import '../../../../core/error/either_typedefs.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class CreateTransaction {
  final TransactionRepository _repository;

  CreateTransaction(this._repository);

  FutureEither<int> call(TransactionEntity entity) {
    return _repository.create(entity);
  }
}
