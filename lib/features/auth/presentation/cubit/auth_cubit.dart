import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  bool _biometricAvailable = false;
  bool _biometricEnabled = true;
  bool _isAuthenticating = false;

  AuthCubit({required AuthRepository repository})
      : _repository = repository,
        super(const AuthInitial());

  bool get isAuthenticated => state is AuthAuthenticated;
  bool get biometricAvailable => _biometricAvailable;
  bool get biometricEnabled => _biometricEnabled;

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());

    final biometricResult = await _repository.isBiometricAvailable();
    _biometricAvailable = biometricResult.getOrElse((_) => false);

    final enabledResult = await _repository.isBiometricEnabled();
    _biometricEnabled = enabledResult.getOrElse((_) => true);

    final effectiveBiometric = _biometricAvailable && _biometricEnabled;

    final hasPinResult = await _repository.hasPin();
    final hasPin = hasPinResult.getOrElse((_) => false);

    if (!hasPin) {
      final onboardingResult = await _repository.isOnboardingCompleted();
      final onboardingDone = onboardingResult.getOrElse((_) => false);
      if (!onboardingDone) {
        emit(const AuthOnboarding());
      } else {
        emit(const AuthPinSetupRequired());
      }
    } else {
      emit(AuthLocked(
        biometricAvailable: effectiveBiometric,
        hasPin: true,
      ));
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _repository.setBiometricEnabled(enabled);
    _biometricEnabled = enabled;
  }

  Future<void> authenticateWithBiometrics() async {
    if (_isAuthenticating) return;
    _isAuthenticating = true;
    try {
      final result = await _repository.authenticateWithBiometrics();
      result.fold(
        (failure) => emit(AuthPinError(
          message: failure.message,
          biometricAvailable: _biometricAvailable,
        )),
        (success) {
          if (success) {
            emit(const AuthAuthenticated());
          }
        },
      );
    } finally {
      _isAuthenticating = false;
    }
  }

  Future<void> authenticateWithPin(String pin) async {
    emit(const AuthPinVerifying());
    final result = await _repository.authenticateWithPin(pin);
    result.fold(
      (failure) => emit(AuthPinError(
        message: failure.message,
        biometricAvailable: _biometricAvailable,
      )),
      (success) {
        if (success) {
          emit(const AuthAuthenticated());
        } else {
          emit(AuthPinError(
            message: 'PIN incorrecto',
            biometricAvailable: _biometricAvailable,
          ));
        }
      },
    );
  }

  Future<void> setupPin(String pin) async {
    emit(const AuthLoading());
    final result = await _repository.setPin(pin);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthAuthenticated()),
    );
  }

  Future<void> changePin(String oldPin, String newPin) async {
    emit(const AuthLoading());
    final verifyResult = await _repository.authenticateWithPin(oldPin);
    final verified = verifyResult.getOrElse((_) => false);

    if (!verified) {
      emit(const AuthError('PIN actual incorrecto'));
      return;
    }

    final result = await _repository.setPin(newPin);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthAuthenticated()),
    );
  }

  Future<void> completeOnboarding() async {
    await _repository.completeOnboarding();
    emit(const AuthPinSetupRequired());
  }

  void lock() {
    if (state is AuthAuthenticated) {
      emit(AuthLocked(
        biometricAvailable: _biometricAvailable && _biometricEnabled,
        hasPin: true,
      ));
    }
  }
}
