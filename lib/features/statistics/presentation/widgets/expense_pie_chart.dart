import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/category_stat.dart';

class ExpensePieChart extends StatefulWidget {
  final List<CategoryStat> stats;
  final double totalExpenses;
  final CurrencyFormatter currencyFormatter;

  const ExpensePieChart({
    super.key,
    required this.stats,
    required this.totalExpenses,
    required this.currencyFormatter,
  });

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex =
                        response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: _buildSections(),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.currencyFormatter.format(widget.totalExpenses),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return List.generate(widget.stats.length, (i) {
      final stat = widget.stats[i];
      final isTouched = i == _touchedIndex;
      final radius = isTouched ? 35.0 : 28.0;

      return PieChartSectionData(
        value: stat.totalAmount,
        color: Color(stat.categoryColor),
        radius: radius,
        title: isTouched ? '${stat.percentage.toStringAsFixed(1)}%' : '',
        titleStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onInverseSurface,
        ),
      );
    });
  }
}
