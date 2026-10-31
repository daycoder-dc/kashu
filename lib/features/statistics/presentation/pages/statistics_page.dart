import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/month_selector.dart';
import '../cubit/statistics_cubit.dart';
import '../cubit/statistics_state.dart';
import '../widgets/category_legend.dart';
import '../widgets/expense_bar_chart.dart';
import '../widgets/expense_pie_chart.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late final StatisticsCubit _cubit;
  late DateTime _currentMonth;
  final _currencyFormatter = CurrencyFormatter();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _cubit = sl<StatisticsCubit>();
    _cubit.loadMonth(_currentMonth.month, _currentMonth.year);
  }

  void _onMonthChanged(DateTime month) {
    setState(() => _currentMonth = month);
    _cubit.loadMonth(month.month, month.year);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadisticas'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            MonthSelector(
              currentMonth: _currentMonth,
              onMonthChanged: _onMonthChanged,
            ),
            Expanded(
              child: BlocBuilder<StatisticsCubit, StatisticsState>(
                bloc: _cubit,
                builder: (context, state) {
                  if (state is StatisticsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is StatisticsError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  if (state is StatisticsLoaded) {
                    final stats = state.stats;
                    if (stats.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer
                                    .withAlpha(80),
                                shape: BoxShape.circle,
                              ),
                              child: PhosphorIcon(
                                PhosphorIconsDuotone.chartBar,
                                size: 36,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Sin datos para mostrar',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Registra gastos para ver\ntus estadisticas aqui',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final totalExpenses = stats.fold<double>(
                      0,
                      (sum, s) => sum + s.totalAmount,
                    );

                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Distribucion de gastos',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ExpensePieChart(
                          stats: stats,
                          totalExpenses: totalExpenses,
                          currencyFormatter: _currencyFormatter,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Gastos por categoria',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ExpenseBarChart(stats: stats),
                        const SizedBox(height: 24),
                        Text(
                          'Detalle',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Divider(height: 16),
                        CategoryLegend(
                          stats: stats,
                          currencyFormatter: _currencyFormatter,
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
