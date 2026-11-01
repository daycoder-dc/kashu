import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_monthly_summary.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetMonthlySummary _getMonthlySummary;
  StreamSubscription? _subscription;
  int? _month;
  int? _year;

  DashboardCubit({required GetMonthlySummary getMonthlySummary})
      : _getMonthlySummary = getMonthlySummary,
        super(const DashboardInitial());

  void loadMonth(int month, int year) {
    _month = month;
    _year = year;
    emit(const DashboardLoading());
    _subscription?.cancel();
    _subscription = _getMonthlySummary(month, year).listen(
      (summary) => emit(DashboardLoaded(summary)),
      onError: (e) => emit(DashboardError(e.toString())),
    );
  }

  void refresh() {
    if (_month != null && _year != null) {
      loadMonth(_month!, _year!);
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
