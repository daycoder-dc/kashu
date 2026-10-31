import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../core/enums/transaction_type.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../features/transactions/domain/entities/transaction_entity.dart';

class TransactionTile extends StatelessWidget {
  final TransactionEntity transaction;
  final CurrencyFormatter currencyFormatter;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onPaidChanged;
  final VoidCallback? onDismissed;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.currencyFormatter,
    this.onTap,
    this.onPaidChanged,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor = isExpense
        ? theme.colorScheme.error
        : theme.appColors.income;
    final categoryColor = transaction.categoryColor != null
        ? Color(transaction.categoryColor!)
        : theme.colorScheme.primary;

    final tile = ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: categoryColor.withAlpha(30),
        child: PhosphorIcon(PhosphorIconsDuotone.tag, color: categoryColor, size: 20),
      ),
      title: Text(
        transaction.concept,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${transaction.categoryName ?? ''} · ${DateFormatter.shortDate(transaction.date)}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currencyFormatter.formatSigned(
              transaction.amount,
              isExpense: isExpense,
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
          if (isExpense && onPaidChanged != null) ...[
            const SizedBox(width: 4),
            SizedBox(
              width: 28,
              height: 28,
              child: Checkbox(
                value: transaction.isPaid,
                onChanged: onPaidChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ],
      ),
    );

    if (onDismissed == null) return tile;

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error,
        child: Icon(PhosphorIconsFill.trash, color: theme.colorScheme.onError),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDismissed!(),
      child: tile,
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar transaccion'),
        content: const Text('Esta accion no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
