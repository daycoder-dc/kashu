import '../../../../core/error/either_typedefs.dart';

abstract class AuthRepository {
  FutureEither<bool> authenticateWithBiometrics();
  FutureEither<bool> authenticateWithPin(String pin);
  FutureEither<void> setPin(String pin);
  FutureEither<bool> hasPin();
  FutureEither<bool> isBiometricAvailable();
  FutureEither<bool> isOnboardingCompleted();
  FutureEither<void> completeOnboarding();
}
