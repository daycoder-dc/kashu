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
      scheme: FlexScheme.indigoM3,
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
      scheme: FlexScheme.indigoM3,
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
