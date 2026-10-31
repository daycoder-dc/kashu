import 'package:equatable/equatable.dart';

class MonthlySummary extends Equatable {
  final int month;
  final int year;
  final double totalIncome;
  final double totalExpenses;
  final double totalPaidExpenses;
  final double? budgetAmount;

  const MonthlySummary({
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalPaidExpenses,
    this.budgetAmount,
  });

  double get balance => totalIncome - totalExpenses;

  double get remainingExpenses => totalExpenses - totalPaidExpenses;

  double get availableBalance => totalIncome - totalPaidExpenses;

  @override
  List<Object?> get props => [
        month,
        year,
        totalIncome,
        totalExpenses,
        totalPaidExpenses,
        budgetAmount,
      ];
}
