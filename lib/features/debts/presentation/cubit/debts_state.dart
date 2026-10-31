import 'package:equatable/equatable.dart';

import '../../domain/entities/debt_entity.dart';
import '../../domain/entities/debt_payment_entity.dart';
import '../../domain/entities/debts_summary.dart';

sealed class DebtsState extends Equatable {
  const DebtsState();

  @override
  List<Object?> get props => [];
}

class DebtsInitial extends DebtsState {
  const DebtsInitial();
}

class DebtsLoading extends DebtsState {
  const DebtsLoading();
}

class DebtsLoaded extends DebtsState {
  final DebtsSummary summary;

  const DebtsLoaded({required this.summary});

  @override
  List<Object?> get props => [summary];
}

class DebtDetailLoaded extends DebtsState {
  final DebtEntity debt;
  final List<DebtPaymentEntity> payments;

  const DebtDetailLoaded({required this.debt, required this.payments});

  @override
  List<Object?> get props => [debt, payments];
}

class DebtsError extends DebtsState {
  final String message;

  const DebtsError({required this.message});

  @override
  List<Object?> get props => [message];
}
