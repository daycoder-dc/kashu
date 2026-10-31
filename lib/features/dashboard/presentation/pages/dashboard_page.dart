import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/breathing_icon.dart';
import '../../../../shared/widgets/kpi_card.dart';
import '../../../../shared/widgets/month_selector.dart';
import '../../../../shared/widgets/transaction_tile.dart';
import '../../../transactions/presentation/cubit/transaction_list_cubit.dart';
import '../../../transactions/presentation/cubit/transaction_list_state.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardCubit _dashboardCubit;
  late final TransactionListCubit _transactionListCubit;
  late DateTime _currentMonth;
  final _currencyFormatter = CurrencyFormatter();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _dashboardCubit = sl<DashboardCubit>();
    _transactionListCubit = sl<TransactionListCubit>();
    _loadMonth();
  }

  void _loadMonth() {
    _dashboardCubit.loadMonth(_currentMonth.month, _currentMonth.year);
    _transactionListCubit.loadMonth(_currentMonth.month, _currentMonth.year);
  }

  void _onMonthChanged(DateTime month) {
    setState(() => _currentMonth = month);
    _loadMonth();
  }

  @override
  void dispose() {
    _dashboardCubit.close();
    _transactionListCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kashu'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(PhosphorIconsLight.gear),
            onPressed: () => context.pushNamed('settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('addTransaction'),
        child: Icon(PhosphorIconsBold.plus),
      ),
      body: SafeArea(
        child: Column(
          children: [
            MonthSelector(
              currentMonth: _currentMonth,
              onMonthChanged: _onMonthChanged,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _loadMonth(),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 8),
                    _buildKpiGrid(),
                    const SizedBox(height: 20),
                    Text(
                      'Transacciones recientes',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTransactionList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiGrid() {
    return BlocBuilder<DashboardCubit, DashboardState>(
      bloc: _dashboardCubit,
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const SizedBox(
            height: 140,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is DashboardError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: ${state.message}'),
            ),
          );
        }
        if (state is DashboardLoaded) {
          final s = state.summary;
          final colors = Theme.of(context).appColors;
          final scheme = Theme.of(context).colorScheme;
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              KpiCard(
                title: 'Ingresos',
                value: _currencyFormatter.format(s.totalIncome),
                icon: PhosphorIcon(
                  PhosphorIconsDuotone.arrowDown,
                  size: 18,
                  color: colors.income,
                ),
                valueColor: colors.income,
              ),
              KpiCard(
                title: 'Gastos',
                value: _currencyFormatter.format(s.totalExpenses),
                icon: PhosphorIcon(
                  PhosphorIconsDuotone.arrowUp,
                  size: 18,
                  color: scheme.error,
                ),
                valueColor: scheme.error,
              ),
              KpiCard(
                title: 'Pagado',
                value: _currencyFormatter.format(s.totalPaidExpenses),
                icon: PhosphorIcon(
                  PhosphorIconsDuotone.checkCircle,
                  size: 18,
                  color: colors.warning,
                ),
              ),
              KpiCard(
                title: 'Disponible',
                value: _currencyFormatter.format(s.availableBalance),
                icon: PhosphorIcon(
                  PhosphorIconsDuotone.wallet,
                  size: 18,
                  color: scheme.primary,
                ),
                valueColor: s.availableBalance >= 0
                    ? colors.success
                    : scheme.error,
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTransactionList() {
    return BlocBuilder<TransactionListCubit, TransactionListState>(
      bloc: _transactionListCubit,
      builder: (context, state) {
        if (state is TransactionListLoading) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is TransactionListError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error: ${state.message}'),
          );
        }
        if (state is TransactionListLoaded) {
          final transactions = state.transactions;
          if (transactions.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    BreathingIcon(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withAlpha(80),
                          shape: BoxShape.circle,
                        ),
                        child: PhosphorIcon(
                          PhosphorIconsDuotone.receipt,
                          size: 36,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aun no hay movimientos',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Agrega tu primer ingreso o gasto\npara comenzar a organizar tus finanzas',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }
          final display = transactions.take(5).toList();
          return Column(
            children: [
              ...display.map((t) => TransactionTile(
                    transaction: t,
                    currencyFormatter: _currencyFormatter,
                    onTap: () => context.pushNamed(
                      'addTransaction',
                      extra: t,
                    ),
                  )),
              if (transactions.length > 5)
                TextButton(
                  onPressed: () => context.go('/transactions'),
                  child: const Text('Ver todas'),
                ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
