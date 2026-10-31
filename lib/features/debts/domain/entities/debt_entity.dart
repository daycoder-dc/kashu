import 'package:equatable/equatable.dart';

class DebtEntity extends Equatable {
  final int id;
  final String name;
  final double totalAmount;
  final double interestRate;
  final int totalInstallments;
  final int paidInstallments;
  final double monthlyPayment;
  final DateTime startDate;
  final int categoryId;
  final String categoryName;
  final int categoryColor;
  final int categoryIconCodePoint;
  final bool isActive;

  const DebtEntity({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.interestRate,
    required this.totalInstallments,
    required this.paidInstallments,
    required this.monthlyPayment,
    required this.startDate,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIconCodePoint,
    required this.isActive,
  });

  double get totalCost => monthlyPayment * totalInstallments;
  double get totalInterest => totalCost - totalAmount;
  double get paidAmount => monthlyPayment * paidInstallments;
  double get remainingAmount => totalCost - paidAmount;
  double get progress =>
      totalInstallments > 0 ? paidInstallments / totalInstallments : 0;

  @override
  List<Object?> get props => [
        id, name, totalAmount, interestRate, totalInstallments,
        paidInstallments, monthlyPayment, startDate, categoryId,
        categoryName, categoryColor, categoryIconCodePoint, isActive,
      ];
}
