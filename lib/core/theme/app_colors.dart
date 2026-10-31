import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color income;
  final Color expense;
  final Color warning;
  final Color success;

  const AppColors({
    required this.income,
    required this.expense,
    required this.warning,
    required this.success,
  });

  static const light = AppColors(
    income: Color(0xFF2E7D32),
    expense: Color(0xFFB3261E),
    warning: Color(0xFFE65100),
    success: Color(0xFF2E7D32),
  );

  static const dark = AppColors(
    income: Color(0xFF81C784),
    expense: Color(0xFFEF9A9A),
    warning: Color(0xFFFFB74D),
    success: Color(0xFF81C784),
  );

  @override
  AppColors copyWith({
    Color? income,
    Color? expense,
    Color? warning,
    Color? success,
  }) {
    return AppColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      warning: warning ?? this.warning,
      success: success ?? this.success,
    );
  }

  @override
  AppColors lerp(covariant ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

extension AppColorsExtension on ThemeData {
  AppColors get appColors => extension<AppColors>() ?? AppColors.light;
}
