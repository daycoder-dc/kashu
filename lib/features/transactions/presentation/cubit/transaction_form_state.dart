import 'package:equatable/equatable.dart';

import '../../../../core/enums/transaction_type.dart';
import '../../domain/entities/category_entity.dart';

sealed class TransactionFormState extends Equatable {
  const TransactionFormState();

  @override
  List<Object?> get props => [];
}

class TransactionFormInitial extends TransactionFormState {
  const TransactionFormInitial();
}

class TransactionFormReady extends TransactionFormState {
  final List<CategoryEntity> categories;
  final TransactionType selectedType;

  const TransactionFormReady({
    required this.categories,
    this.selectedType = TransactionType.expense,
  });

  @override
  List<Object?> get props => [categories, selectedType];
}

class TransactionFormSaving extends TransactionFormState {
  const TransactionFormSaving();
}

class TransactionFormSuccess extends TransactionFormState {
  const TransactionFormSuccess();
}

class TransactionFormError extends TransactionFormState {
  final String message;

  const TransactionFormError(this.message);

  @override
  List<Object?> get props => [message];
}
