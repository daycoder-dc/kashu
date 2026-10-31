import 'package:equatable/equatable.dart';

class DebtPaymentEntity extends Equatable {
  final int id;
  final int debtId;
  final int installmentNumber;
  final int month;
  final int year;
  final double amount;
  final bool isPaid;
  final DateTime? paidAt;

  const DebtPaymentEntity({
    required this.id,
    required this.debtId,
    required this.installmentNumber,
    required this.month,
    required this.year,
    required this.amount,
    required this.isPaid,
    this.paidAt,
  });

  @override
  List<Object?> get props => [
        id, debtId, installmentNumber, month, year, amount, isPaid, paidAt,
      ];
}
