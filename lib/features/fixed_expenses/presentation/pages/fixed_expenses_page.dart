import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/enums/transaction_type.dart';
import '../../../../core/utils/icon_registry.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/thousand_separator_formatter.dart';
import '../../../../shared/widgets/breathing_icon.dart';
import '../../../../shared/widgets/kpi_card.dart';
import '../../../../shared/widgets/month_selector.dart';
import '../../../transactions/presentation/cubit/transaction_form_cubit.dart';
import '../../../transactions/presentation/cubit/transaction_form_state.dart';
import '../../domain/entities/fixed_expense_entity.dart';
import '../../domain/entities/fixed_expenses_summary.dart';
import '../cubit/fixed_expenses_cubit.dart';
import '../cubit/fixed_expenses_state.dart';

class FixedExpensesPage extends StatefulWidget {
  const FixedExpensesPage({super.key});

  @override
  State<FixedExpensesPage> createState() => _FixedExpensesPageState();
}

class _FixedExpensesPageState extends State<FixedExpensesPage> {
  late final FixedExpensesCubit _cubit;
  late DateTime _currentMonth;
  final _currencyFormatter = CurrencyFormatter();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _cubit = sl<FixedExpensesCubit>();
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
        title: const Text('Gastos Fijos'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
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
              child: BlocBuilder<FixedExpensesCubit, FixedExpensesState>(
                bloc: _cubit,
                builder: (context, state) {
                  if (state is FixedExpensesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is FixedExpensesError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  if (state is FixedExpensesLoaded) {
                    return _buildContent(context, state.summary);
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

  Widget _buildContent(BuildContext context, FixedExpensesSummary summary) {
    final theme = Theme.of(context);

    if (summary.expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BreathingIcon(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withAlpha(80),
                  shape: BoxShape.circle,
                ),
                child: PhosphorIcon(
                  PhosphorIconsDuotone.clipboardText,
                  size: 36,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin gastos fijos',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Agrega tus gastos mensuales recurrentes\npara llevar control de lo que pagas',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 8),
        _buildKpiGrid(summary),
        const SizedBox(height: 16),
        _buildProgressBar(summary, theme),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              'Gastos del mes',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${summary.paidCount}/${summary.totalCount} pagados',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...summary.expenses.map(
            (expense) => _buildExpenseTile(context, expense, theme)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildKpiGrid(FixedExpensesSummary summary) {
    final theme = Theme.of(context);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.7,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        KpiCard(
          title: 'Gastos Total',
          value: _currencyFormatter.format(summary.totalExpenses),
          icon: PhosphorIcon(
            PhosphorIconsDuotone.arrowUp,
            size: 18,
            color: theme.colorScheme.error,
          ),
          valueColor: theme.colorScheme.error,
        ),
        KpiCard(
          title: 'Gasto Restante',
          value: _currencyFormatter.format(summary.totalRemaining),
          icon: PhosphorIcon(
            PhosphorIconsDuotone.warning,
            size: 18,
            color: theme.appColors.warning,
          ),
          valueColor: theme.appColors.warning,
        ),
        KpiCard(
          title: 'Salario',
          value: _currencyFormatter.format(summary.salary),
          icon: PhosphorIcon(
            PhosphorIconsDuotone.currencyDollar,
            size: 18,
            color: theme.appColors.success,
          ),
          valueColor: theme.appColors.success,
        ),
        KpiCard(
          title: 'Saldo Restante',
          value: _currencyFormatter.format(summary.salaryRemaining),
          icon: PhosphorIcon(
            PhosphorIconsDuotone.wallet,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          valueColor: summary.salaryRemaining >= 0
              ? theme.appColors.success
              : theme.colorScheme.error,
        ),
      ],
    );
  }

  Widget _buildProgressBar(FixedExpensesSummary summary, ThemeData theme) {
    final progress = summary.totalExpenses > 0
        ? summary.totalPaid / summary.totalExpenses
        : 0.0;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor:
                theme.colorScheme.surfaceContainerHighest,
            color: theme.appColors.success,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pagado: ${_currencyFormatter.format(summary.totalPaid)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.appColors.success,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpenseTile(
      BuildContext context, FixedExpenseEntity expense, ThemeData theme) {
    final color = Color(expense.categoryColor);
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showAddEditDialog(context, expense: expense),
        onLongPress: () => _showDeleteDialog(context, expense),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  resolveIcon(expense.categoryIconCodePoint),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: expense.isPaidThisMonth
                            ? TextDecoration.lineThrough
                            : null,
                        color: expense.isPaidThisMonth
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                    Text(
                      expense.categoryName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _currencyFormatter.format(expense.amount),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 32,
                height: 32,
                child: Checkbox(
                  value: expense.isPaidThisMonth,
                  onChanged: (value) {
                    _cubit.togglePayment(
                      expense.id,
                      _currentMonth.month,
                      _currentMonth.year,
                      value ?? false,
                    );
                  },
                  activeColor: theme.appColors.success,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, FixedExpenseEntity expense) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar gasto fijo'),
        content: Text(
            '¿Eliminar "${expense.name}" de tus gastos fijos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cubit.deleteFixedExpense(
                expense.id,
                _currentMonth.month,
                _currentMonth.year,
              );
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context,
      {FixedExpenseEntity? expense}) {
    final isEdit = expense != null;
    final nameController =
        TextEditingController(text: isEdit ? expense.name : '');
    final amountController = TextEditingController(
        text: isEdit ? ThousandSeparatorFormatter.format(expense.amount) : '');
    int? selectedCategoryId = isEdit ? expense.categoryId : null;

    final formCubit = sl<TransactionFormCubit>();
    formCubit.loadCategories(TransactionType.expense);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEdit ? 'Editar gasto fijo' : 'Nuevo gasto fijo',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      hintText: 'Ej: Hipoteca, Internet...',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Monto mensual',
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandSeparatorFormatter()],
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<TransactionFormCubit, TransactionFormState>(
                    bloc: formCubit,
                    builder: (ctx, formState) {
                      if (formState is! TransactionFormReady) {
                        return const SizedBox.shrink();
                      }
                      final categories = formState.categories;
                      return DropdownButtonFormField<int>(
                        initialValue: selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Categoria',
                        ),
                        items: categories
                            .map((c) => DropdownMenuItem<int>(
                                  value: c.id,
                                  child: Row(
                                    children: [
                                      Icon(
                                        c.iconData,
                                        color: c.displayColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(c.name),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) {
                          setSheetState(() => selectedCategoryId = v);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      final amount =
                          ThousandSeparatorFormatter.parse(amountController.text.trim());
                      if (name.isEmpty ||
                          amount == null ||
                          selectedCategoryId == null) {
                        return;
                      }
                      Navigator.pop(ctx);
                      if (isEdit) {
                        _cubit.updateFixedExpense(
                          id: expense.id,
                          name: name,
                          amount: amount,
                          categoryId: selectedCategoryId!,
                          currentMonth: _currentMonth.month,
                          currentYear: _currentMonth.year,
                        );
                      } else {
                        _cubit.createFixedExpense(
                          name: name,
                          amount: amount,
                          categoryId: selectedCategoryId!,
                          currentMonth: _currentMonth.month,
                          currentYear: _currentMonth.year,
                        );
                      }
                    },
                    child: Text(isEdit ? 'Guardar' : 'Agregar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) => formCubit.close());
  }
}
