import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/either_typedefs.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDatasource _datasource;

  static const _currencyKey = 'currency_code';
  static const _themeModeKey = 'theme_mode';

  SettingsRepositoryImpl({required SettingsLocalDatasource datasource})
      : _datasource = datasource;

  @override
  FutureEither<AppSettings> getSettings() async {
    try {
      final all = await _datasource.getAll();
      final currency = all[_currencyKey] ?? AppConstants.defaultCurrencyCode;
      final themeStr = all[_themeModeKey] ?? 'system';

      return Right(AppSettings(
        currencyCode: currency,
        themeMode: _parseThemeMode(themeStr),
      ));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<void> updateCurrency(String currencyCode) async {
    try {
      await _datasource.setValue(_currencyKey, currencyCode);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<void> updateThemeMode(String themeMode) async {
    try {
      await _datasource.setValue(_themeModeKey, themeMode);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<double?> getBudget(int month, int year) async {
    try {
      final amount = await _datasource.getBudget(month, year);
      return Right(amount);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<void> setBudget(int month, int year, double amount) async {
    try {
      await _datasource.setBudget(month, year, amount);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  ThemeMode _parseThemeMode(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
