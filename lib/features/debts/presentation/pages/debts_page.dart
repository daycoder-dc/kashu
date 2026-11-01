import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../shared/widgets/breathing_icon.dart';
import '../../../../core/database/daos/debt_dao.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/icon_registry.dart';
import '../../../../core/utils/thousand_separator_formatter.dart';
import '../../../../shared/widgets/kpi_card.dart';
import '../../domain/entities/debt_entity.dart';
import '../cubit/debts_cubit.dart';
import '../cubit/debts_state.dart';

class DebtsPage extends StatefulWidget {
  const DebtsPage({super.key});

  @override
  State<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends State<DebtsPage> {
  late final DebtsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<DebtsCubit>();
    _cubit.loadDebts();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Creditos'),
        actions: [
          IconButton(
            icon: Icon(PhosphorIconsLight.gear),
            onPressed: () => context.pushNamed('settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDebtSheet(context),
        child: const Icon(Icons.add),
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
          if (state is! DebtsLoaded) {
            return const SizedBox.shrink();
          }
          final summary = state.summary;

          return ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: [
              Row(
                children: [
                  Expanded(
                    child: KpiCard(
                      title: 'Deuda total',
                      value: currencyFormat.format(summary.totalDebt),
                      icon: Icon(PhosphorIconsLight.bank, size: 16,
                          color: scheme.error),
                      valueColor: scheme.error,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: KpiCard(
                      title: 'Pagado',
                      value: currencyFormat.format(summary.totalPaid),
                      icon: Icon(PhosphorIconsLight.checkCircle, size: 16,
                          color: colors.income),
                      valueColor: colors.income,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              Row(
                children: [
                  Expanded(
                    child: KpiCard(
                      title: 'Restante',
                      value: currencyFormat.format(summary.totalRemaining),
                      icon: Icon(PhosphorIconsLight.hourglass, size: 16,
                          color: colors.warning),
                      valueColor: colors.warning,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: KpiCard(
                      title: 'Cuota mensual',
                      value: currencyFormat.format(summary.totalMonthlyPayments),
                      icon: Icon(PhosphorIconsLight.calendarCheck, size: 16,
                          color: scheme.primary),
                      valueColor: scheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xl),
              if (summary.debts.isEmpty)
                _EmptyState()
              else
                ...summary.debts.map((debt) => _DebtTile(
                      debt: debt,
                      currencyFormat: currencyFormat,
                      onTap: () => context.push('/debts/${debt.id}'),
                      onDelete: () => _confirmDelete(debt),
                    )),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(DebtEntity debt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar credito'),
        content: Text('Eliminar "${debt.name}" y todos sus pagos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cubit.deleteDebt(debt.id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showAddDebtSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddDebtForm(
        onSave: (name, totalAmount, interestRate, installments,
            monthlyPayment, startDate, categoryId) {
          _cubit.createDebt(
            name: name,
            totalAmount: totalAmount,
            interestRate: interestRate,
            totalInstallments: installments,
            monthlyPayment: monthlyPayment,
            startDate: startDate,
            categoryId: categoryId,
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          children: [
            BreathingIcon(
              child: Icon(
                PhosphorIconsLight.creditCard,
                size: 64,
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              'Sin creditos registrados',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              'Toca + para agregar un credito',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebtTile extends StatelessWidget {
  final DebtEntity debt;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DebtTile({
    required this.debt,
    required this.currencyFormat,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.appColors;

    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    resolveIcon(debt.categoryIconCodePoint),
                    color: Color(debt.categoryColor),
                    size: 20,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(debt.name,
                        style: theme.textTheme.titleSmall),
                  ),
                  IconButton(
                    icon: Icon(PhosphorIconsLight.trash,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant),
                    onPressed: onDelete,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: debt.progress,
                  minHeight: 6,
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(
                    debt.progress >= 1.0 ? colors.success : colors.income,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${debt.paidInstallments}/${debt.totalInstallments} cuotas',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${currencyFormat.format(debt.monthlyPayment)}/mes',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddDebtForm extends StatefulWidget {
  final void Function(String name, double totalAmount, double interestRate,
      int installments, double monthlyPayment, DateTime startDate,
      int categoryId) onSave;

  const _AddDebtForm({required this.onSave});

  @override
  State<_AddDebtForm> createState() => _AddDebtFormState();
}

class _AddDebtFormState extends State<_AddDebtForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _rateController = TextEditingController();
  final _installmentsController = TextEditingController();
  final _monthlyController = TextEditingController();
  DateTime _startDate = DateTime.now();
  final int _categoryId = 1;
  bool _autoCalculate = true;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _rateController.dispose();
    _installmentsController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  void _recalculate() {
    if (!_autoCalculate) return;
    final amount = ThousandSeparatorFormatter.parse(_amountController.text);
    final rate = double.tryParse(_rateController.text);
    final installments = int.tryParse(_installmentsController.text);
    if (amount != null && rate != null && installments != null &&
        installments > 0 && amount > 0) {
      final monthly = DebtDao.calculateMonthlyPayment(
          amount, rate, installments);
      _monthlyController.text = ThousandSeparatorFormatter.format(monthly);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: Spacing.lg,
        right: Spacing.lg,
        top: Spacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + Spacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Nuevo credito', style: theme.textTheme.titleMedium),
              const SizedBox(height: Spacing.lg),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del credito',
                  hintText: 'Ej: Hipoteca, Vehiculo',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: Spacing.md),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Monto total',
                  prefixIcon: Icon(PhosphorIconsLight.currencyDollar),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandSeparatorFormatter()],
                onChanged: (_) => _recalculate(),
                validator: (v) {
                  final n = ThousandSeparatorFormatter.parse(v ?? '');
                  return (n == null || n <= 0) ? 'Monto invalido' : null;
                },
              ),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rateController,
                      decoration: const InputDecoration(
                        labelText: 'Tasa anual %',
                        suffixText: '%',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => _recalculate(),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        return (n == null || n < 0) ? 'Invalido' : null;
                      },
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _installmentsController,
                      decoration: const InputDecoration(
                        labelText: '# Cuotas',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      onChanged: (_) => _recalculate(),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        return (n == null || n <= 0) ? 'Invalido' : null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _monthlyController,
                      decoration: const InputDecoration(
                        labelText: 'Cuota mensual',
                        prefixIcon: Icon(PhosphorIconsLight.money),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [ThousandSeparatorFormatter()],
                      enabled: !_autoCalculate,
                      validator: (v) {
                        final n = ThousandSeparatorFormatter.parse(v ?? '');
                        return (n == null || n <= 0)
                            ? 'Cuota invalida'
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Column(
                    children: [
                      Text('Auto', style: theme.textTheme.labelSmall),
                      Switch(
                        value: _autoCalculate,
                        onChanged: (v) {
                          setState(() => _autoCalculate = v);
                          if (v) _recalculate();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(PhosphorIconsLight.calendar),
                title: const Text('Fecha de inicio'),
                subtitle: Text(DateFormat('MMM yyyy', 'es')
                    .format(_startDate)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _pickDate,
              ),
              const SizedBox(height: Spacing.lg),
              FilledButton(
                onPressed: _submit,
                child: const Text('Crear credito'),
              ),
              const SizedBox(height: Spacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(
      _nameController.text.trim(),
      ThousandSeparatorFormatter.parse(_amountController.text) ?? 0,
      double.parse(_rateController.text),
      int.parse(_installmentsController.text),
      ThousandSeparatorFormatter.parse(_monthlyController.text) ?? 0,
      _startDate,
      _categoryId,
    );
    Navigator.pop(context);
  }
}
