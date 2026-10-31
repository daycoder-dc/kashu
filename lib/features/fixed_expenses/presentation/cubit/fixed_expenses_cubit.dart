import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/fixed_expense_repository.dart';
import 'fixed_expenses_state.dart';

class FixedExpensesCubit extends Cubit<FixedExpensesState> {
  final FixedExpenseRepository _repository;

  FixedExpensesCubit({required FixedExpenseRepository repository})
      : _repository = repository,
        super(const FixedExpensesInitial());

  Future<void> loadMonth(int month, int year) async {
    emit(const FixedExpensesLoading());
    final result = await _repository.getSummary(month, year);
    result.fold(
      (failure) => emit(FixedExpensesError(message: failure.message)),
      (summary) => emit(FixedExpensesLoaded(summary: summary)),
    );
  }

  Future<void> togglePayment(
      int fixedExpenseId, int month, int year, bool isPaid) async {
    await _repository.togglePayment(
      fixedExpenseId: fixedExpenseId,
      month: month,
      year: year,
      isPaid: isPaid,
    );
    await loadMonth(month, year);
  }

  Future<void> createFixedExpense({
    required String name,
    required double amount,
    required int categoryId,
    required int currentMonth,
    required int currentYear,
  }) async {
    await _repository.createFixedExpense(
      name: name,
      amount: amount,
      categoryId: categoryId,
    );
    await loadMonth(currentMonth, currentYear);
  }

  Future<void> updateFixedExpense({
    required int id,
    required String name,
    required double amount,
    required int categoryId,
    required int currentMonth,
    required int currentYear,
  }) async {
    await _repository.updateFixedExpense(
      id: id,
      name: name,
      amount: amount,
      categoryId: categoryId,
    );
    await loadMonth(currentMonth, currentYear);
  }

  Future<void> deleteFixedExpense(
      int id, int currentMonth, int currentYear) async {
    await _repository.deleteFixedExpense(id);
    await loadMonth(currentMonth, currentYear);
  }
}
