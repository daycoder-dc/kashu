import 'package:equatable/equatable.dart';

import '../../../../core/enums/transaction_type.dart';

class TransactionEntity extends Equatable {
  final int id;
  final String concept;
  final double amount;
  final TransactionType type;
  final bool isPaid;
  final String? imagePath;
  final DateTime date;
  final int categoryId;
  final String? categoryName;
  final int? categoryColor;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionEntity({
    required this.id,
    required this.concept,
    required this.amount,
    required this.type,
    required this.isPaid,
    this.imagePath,
    required this.date,
    required this.categoryId,
    this.categoryName,
    this.categoryColor,
    required this.createdAt,
    required this.updatedAt,
  });

  TransactionEntity copyWith({
    int? id,
    String? concept,
    double? amount,
    TransactionType? type,
    bool? isPaid,
    String? imagePath,
    DateTime? date,
    int? categoryId,
    String? categoryName,
    int? categoryColor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      concept: concept ?? this.concept,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      isPaid: isPaid ?? this.isPaid,
      imagePath: imagePath ?? this.imagePath,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        concept,
        amount,
        type,
        isPaid,
        imagePath,
        date,
        categoryId,
        categoryName,
        categoryColor,
        createdAt,
        updatedAt,
      ];
}
