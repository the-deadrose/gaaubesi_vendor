class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ServerException(
    this.message, {
    this.statusCode,
    this.data,
  });

  /// Converts the exception to a structured API error response format
  /// Returns: {success: false, message: String, data: null}
  Map<String, dynamic> toErrorResponse() {
    return {
      'success': false,
      'message': message,
      'data': data,
    };
  }
}

class CacheException implements Exception {
  final String message;
  final dynamic data;

  CacheException(this.message, {this.data});

  Map<String, dynamic> toErrorResponse() {
    return {
      'success': false,
      'message': message,
      'data': data,
    };
  }
}

class UnauthorizedException implements Exception {
  final String message;
  final dynamic data;

  UnauthorizedException(this.message, {this.data});

  Map<String, dynamic> toErrorResponse() {
    return {
      'success': false,
      'message': message,
      'data': data,
    };
  }
}

class NetworkException implements Exception {
  final String message;
  final dynamic data;

  NetworkException(this.message, {this.data});

  Map<String, dynamic> toErrorResponse() {
    return {
      'success': false,
      'message': message,
      'data': data,
    };
  }
}
