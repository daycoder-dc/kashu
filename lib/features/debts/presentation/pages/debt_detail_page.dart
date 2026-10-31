import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/debt_payment_entity.dart';
import '../cubit/debts_cubit.dart';
import '../cubit/debts_state.dart';

class DebtDetailPage extends StatefulWidget {
  final int debtId;

  const DebtDetailPage({super.key, required this.debtId});

  @override
  State<DebtDetailPage> createState() => _DebtDetailPageState();
}

class _DebtDetailPageState extends State<DebtDetailPage> {
  late final DebtsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<DebtsCubit>();
    _cubit.loadDebtDetail(widget.debtId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.appColors;
    final scheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(
      locale: 'es',
      symbol: '\$',
      decimalDigits: 0,
    );
    final monthFormat = DateFormat('MMM yyyy', 'es');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del credito'),
      ),
      body: BlocBuilder<DebtsCubit, DebtsState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state is DebtsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DebtsError) {
            return Center(child: Text(state.message));
          }
          if (state is! DebtDetailLoaded) {
            return const SizedBox.shrink();
          }

          final debt = state.debt;
          final payments = state.payments;

          return ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            IconData(debt.categoryIconCodePoint,
                                fontFamily: 'MaterialIcons'),
                            color: Color(debt.categoryColor),
                          ),
                          const SizedBox(width: Spacing.sm),
                          Expanded(
                            child: Text(debt.name,
                                style: theme.textTheme.titleMedium),
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.lg),
                      _InfoRow(
                        label: 'Monto total',
                        value: currencyFormat.format(debt.totalAmount),
                      ),
                      _InfoRow(
                        label: 'Tasa de interes',
                        value: '${debt.interestRate.toStringAsFixed(1)}% anual',
                      ),
                      _InfoRow(
                        label: 'Cuota mensual',
                        value: currencyFormat.format(debt.monthlyPayment),
                      ),
                      _InfoRow(
                        label: 'Total a pagar',
                        value: currencyFormat.format(debt.totalCost),
                      ),
                      _InfoRow(
                        label: 'Intereses totales',
                        value: currencyFormat.format(debt.totalInterest),
                        valueColor: scheme.error,
                      ),
                      const SizedBox(height: Spacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: debt.progress,
                          minHeight: 8,
                          backgroundColor:
                              scheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(
                            debt.progress >= 1.0
                                ? colors.success
                                : colors.income,
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        '${debt.paidInstallments}/${debt.totalInstallments} cuotas pagadas  ·  ${(debt.progress * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                'Cuotas',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              ...payments.map((p) => _PaymentTile(
                    payment: p,
                    currencyFormat: currencyFormat,
                    monthFormat: monthFormat,
                    onToggle: (isPaid) => _cubit.togglePayment(
                        p.id, isPaid, widget.debtId),
                  )),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
          Text(value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              )),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final DebtPaymentEntity payment;
  final NumberFormat currencyFormat;
  final DateFormat monthFormat;
  final ValueChanged<bool> onToggle;

  const _PaymentTile({
    required this.payment,
    required this.currencyFormat,
    required this.monthFormat,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.appColors;
    final date = DateTime(payment.year, payment.month);

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        leading: Checkbox(
          value: payment.isPaid,
          onChanged: (v) => onToggle(v ?? false),
          activeColor: colors.success,
        ),
        title: Text(
          '#${payment.installmentNumber}  ·  ${monthFormat.format(date)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            decoration: payment.isPaid
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        trailing: Text(
          currencyFormat.format(payment.amount),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: payment.isPaid
                ? colors.success
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
