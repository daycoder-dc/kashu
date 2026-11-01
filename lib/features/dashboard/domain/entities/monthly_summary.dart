import 'package:equatable/equatable.dart';

class MonthlySummary extends Equatable {
  final int month;
  final int year;
  final double totalIncome;
  final double totalExpenses;
  final double totalPaidExpenses;
  final double fixedExpensesTotal;
  final double fixedExpensesPaid;
  final double debtPaymentsTotal;
  final double debtPaymentsPaid;
  final double? budgetAmount;

  const MonthlySummary({
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalPaidExpenses,
    this.fixedExpensesTotal = 0,
    this.fixedExpensesPaid = 0,
    this.debtPaymentsTotal = 0,
    this.debtPaymentsPaid = 0,
    this.budgetAmount,
  });

  double get allExpenses =>
      totalExpenses + fixedExpensesTotal + debtPaymentsTotal;

  double get allPaid =>
      totalPaidExpenses + fixedExpensesPaid + debtPaymentsPaid;

  double get balance => totalIncome - allExpenses;

  double get remainingExpenses => totalExpenses - totalPaidExpenses;

  double get availableBalance => totalIncome - allExpenses;

  @override
  List<Object?> get props => [
        month,
        year,
        totalIncome,
        totalExpenses,
        totalPaidExpenses,
        fixedExpensesTotal,
        fixedExpensesPaid,
        debtPaymentsTotal,
        debtPaymentsPaid,
        budgetAmount,
      ];
}
