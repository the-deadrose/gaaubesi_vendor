import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/constants/constants.dart';
import 'package:gaaubesi_vendor/core/network/logger_interceptor.dart';
import 'package:gaaubesi_vendor/core/services/secure_storage_service.dart';

@lazySingleton
class DioClient {
  final Dio _dio;
  final SecureStorageService _secureStorageService;

  DioClient(this._dio, this._secureStorageService) {
    _dio
      ..options.baseUrl = AppConstants.baseUrl
      ..options.connectTimeout = const Duration(
        milliseconds: AppConstants.connectTimeout,
      )
      ..options.receiveTimeout = const Duration(
        milliseconds: AppConstants.receiveTimeout,
      )
      ..options.responseType = ResponseType.json
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // Skip adding token for auth endpoints
            final isAuthEndpoint =
                options.path.contains('/login') ||
                options.path.contains('/register');

            if (!isAuthEndpoint) {
              final token = await _secureStorageService.read(
                key: AppConstants.tokenKey,
              );
              if (token != null) {
                options.headers['Authorization'] = 'Token $token';
              }
            }
            return handler.next(options);
          },
          onError: (DioException e, handler) async {
            if (e.response?.statusCode == 401) {
              await _secureStorageService.delete(key: AppConstants.tokenKey);
            }

            // Global Error Parsing
            String errorMessage = e.message ?? 'An unexpected error occurred';
            if (e.response?.data != null) {
              final data = e.response?.data;
              if (data is Map<String, dynamic>) {
                if (data.containsKey('non_field_errors')) {
                  final errors = data['non_field_errors'];
                  if (errors is List && errors.isNotEmpty) {
                    errorMessage = errors.first.toString();
                  }
                } else if (data.containsKey('detail')) {
                  errorMessage = data['detail'].toString();
                } else if (data.isNotEmpty) {
                  final firstValue = data.values.first;
                  if (firstValue is List && firstValue.isNotEmpty) {
                    errorMessage = firstValue.first.toString();
                  } else {
                    errorMessage = firstValue.toString();
                  }
                }
              } else if (data is String) {
                errorMessage = data;
              }
            }

            final newError = DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: e.error,
              message: errorMessage,
            );

            return handler.next(newError);
          },
        ),
      );
    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LoggerInterceptor());
    }
  }

  Dio get dio => _dio;

  // Expose common methods if needed, or just use dio directly in repositories
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
