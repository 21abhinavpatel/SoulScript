import 'package:fpdart/fpdart.dart';
import 'package:soulscript/core/failures.dart';

abstract interface class UseCase<SuccessType, Parameters> {
  Future<Either<Failure, SuccessType>> call(Parameters parameters);
}

class NoParameters {}

abstract class StreamUseCase<SuccessType, Parameters> {
  Stream<Either<Failure, SuccessType>> call(Parameters parameters);
}