import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/debt_repository.dart';
import 'debts_state.dart';

class DebtsCubit extends Cubit<DebtsState> {
  final DebtRepository _repository;

  DebtsCubit({required DebtRepository repository})
      : _repository = repository,
        super(const DebtsInitial());

  Future<void> loadDebts() async {
    emit(const DebtsLoading());
    final result = await _repository.getSummary();
    result.fold(
      (failure) => emit(DebtsError(message: failure.message)),
      (summary) => emit(DebtsLoaded(summary: summary)),
    );
  }

  Future<void> loadDebtDetail(int debtId) async {
    emit(const DebtsLoading());
    final debtResult = await _repository.getDebtById(debtId);
    final paymentsResult = await _repository.getPayments(debtId);

    debtResult.fold(
      (failure) => emit(DebtsError(message: failure.message)),
      (debt) => paymentsResult.fold(
        (failure) => emit(DebtsError(message: failure.message)),
        (payments) =>
            emit(DebtDetailLoaded(debt: debt, payments: payments)),
      ),
    );
  }

  Future<void> createDebt({
    required String name,
    required double totalAmount,
    required double interestRate,
    required int totalInstallments,
    required double monthlyPayment,
    required DateTime startDate,
    required int categoryId,
  }) async {
    await _repository.createDebt(
      name: name,
      totalAmount: totalAmount,
      interestRate: interestRate,
      totalInstallments: totalInstallments,
      monthlyPayment: monthlyPayment,
      startDate: startDate,
      categoryId: categoryId,
    );
    await loadDebts();
  }

  Future<void> deleteDebt(int id) async {
    await _repository.deleteDebt(id);
    await loadDebts();
  }

  Future<void> togglePayment(int paymentId, bool isPaid, int debtId) async {
    await _repository.togglePayment(paymentId: paymentId, isPaid: isPaid);
    await loadDebtDetail(debtId);
  }
}
