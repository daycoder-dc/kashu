import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;

  SettingsCubit({required SettingsRepository repository})
      : _repository = repository,
        super(const SettingsInitial());

  Future<void> loadSettings() async {
    emit(const SettingsLoading());
    final result = await _repository.getSettings();
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (settings) => emit(SettingsLoaded(settings: settings)),
    );
  }

  Future<void> updateCurrency(String currencyCode) async {
    final result = await _repository.updateCurrency(currencyCode);
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (_) {
        final current = state;
        if (current is SettingsLoaded) {
          emit(current.copyWith(
            settings: current.settings.copyWith(currencyCode: currencyCode),
          ));
        }
      },
    );
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    final modeStr = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    final result = await _repository.updateThemeMode(modeStr);
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (_) {
        final current = state;
        if (current is SettingsLoaded) {
          emit(current.copyWith(
            settings: current.settings.copyWith(themeMode: mode),
          ));
        }
      },
    );
  }

  Future<void> loadBudget(int month, int year) async {
    final result = await _repository.getBudget(month, year);
    result.fold(
      (_) {},
      (amount) {
        final current = state;
        if (current is SettingsLoaded) {
          emit(current.copyWith(budgetAmount: amount));
        }
      },
    );
  }

  Future<void> setBudget(int month, int year, double amount) async {
    final result = await _repository.setBudget(month, year, amount);
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (_) {
        final current = state;
        if (current is SettingsLoaded) {
          emit(current.copyWith(budgetAmount: amount));
        }
      },
    );
  }
}
