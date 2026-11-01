import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class Spacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

class AppTheme {
  static const _brandPrimary = Color(0xFF4F46E5);

  static const _colors = FlexSchemeColor(
    primary: _brandPrimary,
    primaryContainer: Color(0xFFE0DEFF),
    secondary: Color(0xFF5C6BC0),
    secondaryContainer: Color(0xFFDDE1FF),
    tertiary: Color(0xFF7C4DFF),
    tertiaryContainer: Color(0xFFEDE7FF),
  );

  static const _darkColors = FlexSchemeColor(
    primary: Color(0xFFB8B3FF),
    primaryContainer: Color(0xFF3730A3),
    secondary: Color(0xFF9FA8DA),
    secondaryContainer: Color(0xFF3949AB),
    tertiary: Color(0xFFCEB5FF),
    tertiaryContainer: Color(0xFF5B21B6),
  );

  static const _subThemes = FlexSubThemesData(
    interactionEffects: true,
    blendOnLevel: 10,
    inputDecoratorBorderType: FlexInputBorderType.outline,
    inputDecoratorRadius: 12.0,
    chipRadius: 20.0,
    cardRadius: 14.0,
    cardElevation: 0,
    dialogRadius: 20.0,
    fabRadius: 16.0,
    appBarScrolledUnderElevation: 0.5,
    navigationBarIndicatorRadius: 12.0,
    navigationBarElevation: 0,
  );

  static ThemeData light() {
    final base = FlexThemeData.light(
      colors: _colors,
      useMaterial3: true,
      textTheme: AppTypography.textTheme,
      subThemesData: _subThemes,
    );
    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: base.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        color: base.colorScheme.surface,
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        elevation: 0,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      extensions: [AppColors.light],
    );
  }

  static ThemeData dark() {
    final base = FlexThemeData.dark(
      colors: _darkColors,
      useMaterial3: true,
      textTheme: AppTypography.textTheme,
      subThemesData: _subThemes.copyWith(blendOnLevel: 20),
    );
    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: base.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        color: base.colorScheme.surface,
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        elevation: 0,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      extensions: [AppColors.dark],
    );
  }
}
