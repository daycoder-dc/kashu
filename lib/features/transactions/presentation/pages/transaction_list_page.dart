import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/month_selector.dart';
import '../../../../shared/widgets/transaction_tile.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../cubit/transaction_list_cubit.dart';
import '../cubit/transaction_list_state.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  late final TransactionListCubit _cubit;
  late DateTime _currentMonth;
  final _currencyFormatter = CurrencyFormatter();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _cubit = sl<TransactionListCubit>();
    _loadMonth();
  }

  void _loadMonth() {
    _cubit.loadMonth(_currentMonth.month, _currentMonth.year);
  }

  void _onMonthChanged(DateTime month) {
    setState(() => _currentMonth = month);
    _loadMonth();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transacciones'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'txn_fab',
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
              child: BlocBuilder<TransactionListCubit, TransactionListState>(
                bloc: _cubit,
                builder: (context, state) {
                  if (state is TransactionListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is TransactionListError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  if (state is TransactionListLoaded) {
                    final transactions = state.transactions;
                    if (transactions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
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
                            const SizedBox(height: 16),
                            Text(
                              'Sin movimientos este mes',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Registra tus gastos e ingresos\npara llevar el control',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: () =>
                                  context.pushNamed('addTransaction'),
                              icon: Icon(PhosphorIconsBold.plus, size: 18),
                              label: const Text('Agregar'),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final t = transactions[index];
                        return TransactionTile(
                          transaction: t,
                          currencyFormatter: _currencyFormatter,
                          onTap: () => context.pushNamed(
                            'addTransaction',
                            extra: t,
                          ),
                          onPaidChanged: (val) async {
                            if (val == null) return;
                            final repo = sl<TransactionRepository>();
                            await repo.togglePaid(t.id, val);
                          },
                          onDismissed: () async {
                            final repo = sl<TransactionRepository>();
                            await repo.delete(t.id);
                          },
                        );
                      },
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
