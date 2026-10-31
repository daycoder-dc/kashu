import 'package:fpdart/fpdart.dart';

import 'failures.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef EitherFailure<T> = Either<Failure, T>;
