import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_category_breakdown.dart';
import 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final GetCategoryBreakdown _getCategoryBreakdown;

  StatisticsCubit({required GetCategoryBreakdown getCategoryBreakdown})
      : _getCategoryBreakdown = getCategoryBreakdown,
        super(const StatisticsInitial());

  Future<void> loadMonth(int month, int year) async {
    emit(const StatisticsLoading());
    final result = await _getCategoryBreakdown(month, year);
    result.fold(
      (failure) => emit(StatisticsError(failure.message)),
      (stats) => emit(StatisticsLoaded(stats)),
    );
  }
}
