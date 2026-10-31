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
      ];
}
