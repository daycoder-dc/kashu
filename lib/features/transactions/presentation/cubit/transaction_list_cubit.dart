import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_transactions_by_month.dart';
import 'transaction_list_state.dart';

class TransactionListCubit extends Cubit<TransactionListState> {
  final GetTransactionsByMonth _getTransactionsByMonth;
  StreamSubscription? _subscription;

  TransactionListCubit(
      {required GetTransactionsByMonth getTransactionsByMonth})
      : _getTransactionsByMonth = getTransactionsByMonth,
        super(const TransactionListInitial());

  void loadMonth(int month, int year) {
    emit(const TransactionListLoading());
    _subscription?.cancel();
    _subscription = _getTransactionsByMonth(month, year).listen(
      (transactions) => emit(TransactionListLoaded(transactions)),
      onError: (e) => emit(TransactionListError(e.toString())),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
