import 'package:equatable/equatable.dart';

import '../../domain/entities/app_settings.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final AppSettings settings;
  final double? budgetAmount;

  const SettingsLoaded({
    required this.settings,
    this.budgetAmount,
  });

  SettingsLoaded copyWith({
    AppSettings? settings,
    double? budgetAmount,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      budgetAmount: budgetAmount ?? this.budgetAmount,
    );
  }

  @override
  List<Object?> get props => [settings, budgetAmount];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
