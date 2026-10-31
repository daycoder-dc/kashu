import 'package:equatable/equatable.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated();
}

class AuthLocked extends AuthState {
  final bool biometricAvailable;
  final bool hasPin;

  const AuthLocked({
    this.biometricAvailable = false,
    this.hasPin = false,
  });

  @override
  List<Object?> get props => [biometricAvailable, hasPin];
}

class AuthOnboarding extends AuthState {
  const AuthOnboarding();
}

class AuthPinSetupRequired extends AuthState {
  const AuthPinSetupRequired();
}

class AuthPinVerifying extends AuthState {
  const AuthPinVerifying();
}

class AuthPinError extends AuthState {
  final String message;
  final bool biometricAvailable;

  const AuthPinError({required this.message, this.biometricAvailable = false});

  @override
  List<Object?> get props => [message, biometricAvailable];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
