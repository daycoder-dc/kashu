import 'package:equatable/equatable.dart';

class MonthlySummary extends Equatable {
  final int month;
  final int year;
  final double totalIncome;
  final double totalExpenses;
  final double totalPaidExpenses;
  final double fixedExpensesPaid;
  final double debtPaymentsPaid;
  final double? budgetAmount;

  const MonthlySummary({
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalPaidExpenses,
    this.fixedExpensesPaid = 0,
    this.debtPaymentsPaid = 0,
    this.budgetAmount,
  });

  double get allExpenses =>
      totalExpenses + fixedExpensesPaid + debtPaymentsPaid;

  double get allPaid =>
      totalPaidExpenses + fixedExpensesPaid + debtPaymentsPaid;

  double get balance => totalIncome - allExpenses;

  double get remainingExpenses => totalExpenses - totalPaidExpenses;

  double get availableBalance => totalIncome - allPaid;

  @override
  List<Object?> get props => [
        month,
        year,
        totalIncome,
        totalExpenses,
        totalPaidExpenses,
        fixedExpensesPaid,
        debtPaymentsPaid,
        budgetAmount,
      ];
}
