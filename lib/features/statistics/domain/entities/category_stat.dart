import 'package:equatable/equatable.dart';

class CategoryStat extends Equatable {
  final String categoryName;
  final int categoryColor;
  final double totalAmount;
  final double percentage;

  const CategoryStat({
    required this.categoryName,
    required this.categoryColor,
    required this.totalAmount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [
        categoryName,
        categoryColor,
        totalAmount,
        percentage,
      ];
}
