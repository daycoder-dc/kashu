import 'package:equatable/equatable.dart';

class FixedExpenseEntity extends Equatable {
  final int id;
  final String name;
  final double amount;
  final int categoryId;
  final String categoryName;
  final int categoryColor;
  final int categoryIconCodePoint;
  final bool isActive;
  final bool isPaidThisMonth;
  final bool isDebtPayment;
  final int? debtPaymentId;
  final int? installmentNumber;
  final int? totalInstallments;

  const FixedExpenseEntity({
    required this.id,
    required this.name,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIconCodePoint,
    required this.isActive,
    required this.isPaidThisMonth,
    this.isDebtPayment = false,
    this.debtPaymentId,
    this.installmentNumber,
    this.totalInstallments,
  });

  FixedExpenseEntity copyWith({
    int? id,
    String? name,
    double? amount,
    int? categoryId,
    String? categoryName,
    int? categoryColor,
    int? categoryIconCodePoint,
    bool? isActive,
    bool? isPaidThisMonth,
    bool? isDebtPayment,
    int? debtPaymentId,
    int? installmentNumber,
    int? totalInstallments,
  }) {
    return FixedExpenseEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
      categoryIconCodePoint:
          categoryIconCodePoint ?? this.categoryIconCodePoint,
      isActive: isActive ?? this.isActive,
      isPaidThisMonth: isPaidThisMonth ?? this.isPaidThisMonth,
      isDebtPayment: isDebtPayment ?? this.isDebtPayment,
      debtPaymentId: debtPaymentId ?? this.debtPaymentId,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      totalInstallments: totalInstallments ?? this.totalInstallments,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        categoryId,
        categoryName,
        categoryColor,
        categoryIconCodePoint,
        isActive,
        isPaidThisMonth,
        isDebtPayment,
        debtPaymentId,
        installmentNumber,
        totalInstallments,
      ];
}
