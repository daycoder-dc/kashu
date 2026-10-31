import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/transaction_type.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/create_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/update_transaction.dart';
import 'transaction_form_state.dart';

class TransactionFormCubit extends Cubit<TransactionFormState> {
  final TransactionRepository _repository;
  final CreateTransaction _createTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;

  TransactionFormCubit({
    required TransactionRepository repository,
    required CreateTransaction createTransaction,
    required UpdateTransaction updateTransaction,
    required DeleteTransaction deleteTransaction,
  })  : _repository = repository,
        _createTransaction = createTransaction,
        _updateTransaction = updateTransaction,
        _deleteTransaction = deleteTransaction,
        super(const TransactionFormInitial());

  Future<void> loadCategories(TransactionType type) async {
    final result = await _repository.getCategories(type.value);
    result.fold(
      (failure) => emit(TransactionFormError(failure.message)),
      (categories) => emit(TransactionFormReady(
        categories: categories,
        selectedType: type,
      )),
    );
  }

  Future<void> switchType(TransactionType type) async {
    await loadCategories(type);
  }

  Future<void> save(TransactionEntity entity) async {
    emit(const TransactionFormSaving());
    final result = entity.id == 0
        ? await _createTransaction(entity)
        : await _updateTransaction(entity);
    result.fold(
      (failure) => emit(TransactionFormError(failure.message)),
      (_) => emit(const TransactionFormSuccess()),
    );
  }

  Future<void> togglePaid(int id, bool isPaid) async {
    final result = await _repository.togglePaid(id, isPaid);
    result.fold(
      (failure) => emit(TransactionFormError(failure.message)),
      (_) {},
    );
  }

  Future<void> delete(int id) async {
    final result = await _deleteTransaction(id);
    result.fold(
      (failure) => emit(TransactionFormError(failure.message)),
      (_) => emit(const TransactionFormSuccess()),
    );
  }
}
