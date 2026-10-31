import 'package:equatable/equatable.dart';

import '../../domain/entities/transaction_entity.dart';

sealed class TransactionListState extends Equatable {
  const TransactionListState();

  @override
  List<Object?> get props => [];
}

class TransactionListInitial extends TransactionListState {
  const TransactionListInitial();
}

class TransactionListLoading extends TransactionListState {
  const TransactionListLoading();
}

class TransactionListLoaded extends TransactionListState {
  final List<TransactionEntity> transactions;

  const TransactionListLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class TransactionListError extends TransactionListState {
  final String message;

  const TransactionListError(this.message);

  @override
  List<Object?> get props => [message];
}
