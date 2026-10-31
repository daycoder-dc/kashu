import 'package:equatable/equatable.dart';

import 'fixed_expense_entity.dart';

class FixedExpensesSummary extends Equatable {
  final List<FixedExpenseEntity> expenses;
  final double totalExpenses;
  final double totalPaid;
  final double totalRemaining;
  final double salary;

  const FixedExpensesSummary({
    required this.expenses,
    required this.totalExpenses,
    required this.totalPaid,
    required this.totalRemaining,
    required this.salary,
  });

  double get salaryRemaining => salary - totalExpenses;

  int get paidCount => expenses.where((e) => e.isPaidThisMonth).length;
  int get totalCount => expenses.length;

  @override
  List<Object?> get props => [
        expenses,
        totalExpenses,
        totalPaid,
        totalRemaining,
        salary,
      ];
}
