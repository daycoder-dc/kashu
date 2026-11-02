import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../../debts/presentation/cubit/debts_cubit.dart';
import '../../domain/repositories/fixed_expense_repository.dart';
import 'fixed_expenses_state.dart';

class FixedExpensesCubit extends Cubit<FixedExpensesState> {
  final FixedExpenseRepository _repository;
  int _month = 0;
  int _year = 0;

  FixedExpensesCubit({required FixedExpenseRepository repository})
      : _repository = repository,
        super(const FixedExpensesInitial());

  Future<void> loadMonth(int month, int year) async {
    _month = month;
    _year = year;
    emit(const FixedExpensesLoading());
    final result = await _repository.getSummary(month, year);
    result.fold(
      (failure) => emit(FixedExpensesError(message: failure.message)),
      (summary) => emit(FixedExpensesLoaded(summary: summary)),
    );
  }

  Future<void> refresh() async {
    if (_month > 0) await loadMonth(_month, _year);
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
    sl<DashboardCubit>().refresh();
  }

  Future<void> toggleDebtPayment(
      int debtPaymentId, int month, int year, bool isPaid) async {
    await _repository.toggleDebtPayment(
      debtPaymentId: debtPaymentId,
      isPaid: isPaid,
    );
    await loadMonth(month, year);
    sl<DashboardCubit>().refresh();
    sl<DebtsCubit>().loadDebts();
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
