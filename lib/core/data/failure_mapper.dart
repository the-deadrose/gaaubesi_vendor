import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';

/// Single source of truth for exception → failure conversion.
Failure toFailure(Object error) {
  if (error is UnauthorizedException) {
    return UnauthorizedFailure(error.message, data: error.data);
  }
  if (error is ValidationException) {
    return ValidationFailure(
      error.message,
      fieldErrors: error.fieldErrors,
      data: error.data,
    );
  }
  if (error is NetworkException) {
    return NetworkFailure(error.message, data: error.data);
  }
  if (error is ServerException) {
    return ServerFailure(
      error.message,
      statusCode: error.statusCode,
      data: error.data,
    );
  }
  if (error is CacheException) {
    return CacheFailure(error.message, data: error.data);
  }
  return ServerFailure(error.toString());
}
