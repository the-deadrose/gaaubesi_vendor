import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;
  final dynamic data;

  const Failure(
    this.message, {
    this.statusCode,
    this.data,
  });

  @override
  List<Object?> get props => [message, statusCode, data];

  /// Converts the failure to a structured API error response format
  /// Returns: {success: false, message: String, data: null}
  Map<String, dynamic> toErrorResponse() {
    return {
      'success': false,
      'message': message,
      'data': data,
    };
  }
}

class ServerFailure extends Failure {
  const ServerFailure(
    super.message, {
    super.statusCode,
    super.data,
  });
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.data});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.data});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message, {super.data});
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure(
    super.message, {
    this.fieldErrors,
    super.data,
  });

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}
