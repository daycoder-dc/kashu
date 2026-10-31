import 'package:equatable/equatable.dart';

import 'debt_entity.dart';

class DebtsSummary extends Equatable {
  final List<DebtEntity> debts;
  final double totalDebt;
  final double totalPaid;
  final double totalRemaining;
  final double totalMonthlyPayments;

  const DebtsSummary({
    required this.debts,
    required this.totalDebt,
    required this.totalPaid,
    required this.totalRemaining,
    required this.totalMonthlyPayments,
  });

  @override
  List<Object?> get props => [
        debts, totalDebt, totalPaid, totalRemaining, totalMonthlyPayments,
      ];
}
