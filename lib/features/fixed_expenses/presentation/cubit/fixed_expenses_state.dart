import 'package:equatable/equatable.dart';

import '../../domain/entities/fixed_expenses_summary.dart';

sealed class FixedExpensesState extends Equatable {
  const FixedExpensesState();

  @override
  List<Object?> get props => [];
}

class FixedExpensesInitial extends FixedExpensesState {
  const FixedExpensesInitial();
}

class FixedExpensesLoading extends FixedExpensesState {
  const FixedExpensesLoading();
}

class FixedExpensesLoaded extends FixedExpensesState {
  final FixedExpensesSummary summary;

  const FixedExpensesLoaded({required this.summary});

  @override
  List<Object?> get props => [summary];
}

class FixedExpensesError extends FixedExpensesState {
  final String message;

  const FixedExpensesError({required this.message});

  @override
  List<Object?> get props => [message];
}
