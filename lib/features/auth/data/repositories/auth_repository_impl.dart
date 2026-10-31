import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../core/error/either_typedefs.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  static const _pinKey = 'kashu_pin';
  static const _onboardingKey = 'kashu_onboarding_completed';

  AuthRepositoryImpl({
    required LocalAuthentication localAuth,
    required FlutterSecureStorage secureStorage,
  })  : _localAuth = localAuth,
        _secureStorage = secureStorage;

  @override
  FutureEither<bool> authenticateWithBiometrics() async {
    try {
      final result = await _localAuth.authenticate(
        localizedReason: 'Autenticarse para acceder a Kashu',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      return Right(result);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<bool> authenticateWithPin(String pin) async {
    try {
      final storedPin = await _secureStorage.read(key: _pinKey);
      return Right(storedPin == pin);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<void> setPin(String pin) async {
    try {
      await _secureStorage.write(key: _pinKey, value: pin);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<bool> hasPin() async {
    try {
      final pin = await _secureStorage.read(key: _pinKey);
      return Right(pin != null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return Right(canCheck && isDeviceSupported);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<bool> isOnboardingCompleted() async {
    try {
      final value = await _secureStorage.read(key: _onboardingKey);
      return Right(value == 'true');
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  FutureEither<void> completeOnboarding() async {
    try {
      await _secureStorage.write(key: _onboardingKey, value: 'true');
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }
}
