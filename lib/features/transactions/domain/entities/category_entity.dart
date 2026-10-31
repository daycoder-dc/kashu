import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/enums/transaction_type.dart';

class CategoryEntity extends Equatable {
  final int id;
  final String name;
  final int iconCodePoint;
  final String iconFontFamily;
  final int color;
  final TransactionType type;
  final bool isDefault;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.iconFontFamily,
    required this.color,
    required this.type,
    required this.isDefault,
  });

  // ignore: non_const_argument_for_const_parameter
  IconData get iconData => IconData(iconCodePoint, fontFamily: iconFontFamily);

  Color get displayColor => Color(color);

  @override
  List<Object?> get props => [
        id,
        name,
        iconCodePoint,
        iconFontFamily,
        color,
        type,
        isDefault,
      ];
}
