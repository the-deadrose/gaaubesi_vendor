import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';

/// Converts a DioException to a typed domain exception.
///
/// Transport-level failures (timeout, no-connection) become [NetworkException].
/// HTTP failures map by status code:
///   401 → [UnauthorizedException]
///   400/422 with field errors → [ValidationException]
///   other → [ServerException]
Object mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return NetworkException('Request timed out');
    case DioExceptionType.connectionError:
      return NetworkException('No internet connection');
    case DioExceptionType.cancel:
      // Already a downstream signal (e.g. session expired logout). Rethrow raw.
      return e;
    case DioExceptionType.badCertificate:
      return NetworkException('Certificate error');
    case DioExceptionType.unknown:
      if (e.error is SocketException) {
        return NetworkException('No internet connection');
      }
      return ServerException(
        e.message ?? 'Unknown error',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    case DioExceptionType.badResponse:
      return _mapBadResponse(e);
  }
}

Object _mapBadResponse(DioException e) {
  final status = e.response?.statusCode;
  final body = e.response?.data;
  final parsed = parseErrorBody(body);
  final message = parsed.message ?? e.message ?? 'Request failed';

  if (status == 401) {
    return UnauthorizedException(message, data: body);
  }

  if ((status == 400 || status == 422) && parsed.fieldErrors != null) {
    return ValidationException(
      message,
      fieldErrors: parsed.fieldErrors,
      data: body,
    );
  }

  return ServerException(message, statusCode: status, data: body);
}

class ParsedErrorBody {
  final String? message;
  final Map<String, List<String>>? fieldErrors;

  const ParsedErrorBody({this.message, this.fieldErrors});
}

/// Walks common API error response shapes and extracts a user-facing message
/// plus any field-level validation errors.
ParsedErrorBody parseErrorBody(dynamic data) {
  if (data == null) return const ParsedErrorBody();

  if (data is String) {
    return ParsedErrorBody(message: data);
  }

  if (data is Map<String, dynamic>) {
    if (data['message'] is String) {
      return ParsedErrorBody(message: data['message'] as String);
    }
    if (data['detail'] is String) {
      return ParsedErrorBody(message: data['detail'] as String);
    }
    if (data['non_field_errors'] is List &&
        (data['non_field_errors'] as List).isNotEmpty) {
      return ParsedErrorBody(
        message: (data['non_field_errors'] as List).first.toString(),
      );
    }

    final fieldErrors = <String, List<String>>{};
    String? firstMessage;
    data.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        final strings = value.map((v) => v.toString()).toList();
        fieldErrors[key] = strings;
        firstMessage ??= strings.first;
      } else if (value is String) {
        fieldErrors[key] = [value];
        firstMessage ??= value;
      }
    });

    if (fieldErrors.isNotEmpty) {
      return ParsedErrorBody(
        message: firstMessage,
        fieldErrors: fieldErrors,
      );
    }
  }

  return const ParsedErrorBody();
}
