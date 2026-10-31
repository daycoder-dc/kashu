import '../../../../core/error/either_typedefs.dart';
import '../repositories/auth_repository.dart';

class AuthenticateUser {
  final AuthRepository _repository;

  AuthenticateUser(this._repository);

  FutureEither<bool> withBiometrics() {
    return _repository.authenticateWithBiometrics();
  }

  FutureEither<bool> withPin(String pin) {
    return _repository.authenticateWithPin(pin);
  }
}
