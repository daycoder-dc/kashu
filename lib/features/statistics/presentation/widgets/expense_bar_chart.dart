import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/category_stat.dart';

class ExpenseBarChart extends StatelessWidget {
  final List<CategoryStat> stats;

  const ExpenseBarChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxAmount =
        stats.isEmpty ? 1.0 : stats.first.totalAmount * 1.15;

    return SizedBox(
      height: (stats.length * 48.0).clamp(120, 360),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxAmount,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final stat = stats[group.x];
                return BarTooltipItem(
                  '${stat.categoryName}\n',
                  theme.textTheme.labelSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: '${stat.percentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= stats.length) {
                    return const SizedBox.shrink();
                  }
                  final name = stats[idx].categoryName;
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      name.length > 8 ? '${name.substring(0, 7)}.' : name,
                      style: theme.textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: _buildGroups(),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildGroups() {
    return List.generate(stats.length, (i) {
      final stat = stats[i];
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: stat.totalAmount,
            color: Color(stat.categoryColor),
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    });
  }
}
