import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

class AppSettings extends Equatable {
  final String currencyCode;
  final ThemeMode themeMode;

  const AppSettings({
    this.currencyCode = AppConstants.defaultCurrencyCode,
    this.themeMode = ThemeMode.system,
  });

  AppSettings copyWith({
    String? currencyCode,
    ThemeMode? themeMode,
  }) {
    return AppSettings(
      currencyCode: currencyCode ?? this.currencyCode,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [currencyCode, themeMode];
}
