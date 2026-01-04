import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/constants/constants.dart';
import 'package:gaaubesi_vendor/core/network/logger_interceptor.dart';
import 'package:gaaubesi_vendor/core/services/secure_storage_service.dart';

@lazySingleton
class DioClient {
  final Dio _dio;
  final SecureStorageService _secureStorageService;
  bool _isRefreshing = false;

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
            final fullUrl = '${_dio.options.baseUrl}${options.path}';
            debugPrint('📤 [DioClient] ${options.method} Request');
            debugPrint('   Full Path: $fullUrl');
            debugPrint('   Query Params: ${options.queryParameters.isNotEmpty ? options.queryParameters : "none"}');
            
            // Skip adding token for auth endpoints
            final isAuthEndpoint = options.path == ApiEndpoints.login ||
                options.path == ApiEndpoints.refreshToken ||
                options.path.contains('/register');

            if (!isAuthEndpoint) {
              final token = await _secureStorageService.read(
                key: AppConstants.tokenKey,
              );
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
                debugPrint('✅ [DioClient] Authorization header added (token length: ${token.length})');
              } else {
                debugPrint('⚠️  [DioClient] No token found for non-auth endpoint');
              }
            } else {
              debugPrint('⏭️  [DioClient] Skipping token for auth endpoint');
            }
            return handler.next(options);
          },
          onError: (DioException e, handler) async {
            final fullUrl = '${_dio.options.baseUrl}${e.requestOptions.path}';
            debugPrint('❌ [DioClient] Error Response');
            debugPrint('   Full Path: $fullUrl');
            debugPrint('   Method: ${e.requestOptions.method}');
            debugPrint('   Status: ${e.response?.statusCode}');
            debugPrint('   Message: ${e.message}');
            
            // Handle 401 Unauthorized - Try to refresh token
            if (e.response?.statusCode == 401 &&
                e.requestOptions.path != ApiEndpoints.refreshToken) {
              debugPrint('🔄 [DioClient] Attempting token refresh...');
              return _handleTokenRefresh(e, handler);
            }

            // If refresh token is invalid/expired, logout user
            if (e.response?.statusCode == 401 &&
                e.requestOptions.path == ApiEndpoints.refreshToken) {
              debugPrint('🚪 [DioClient] Refresh token expired, logging out user');
              await _logoutUser();
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

  Future<dynamic> _handleTokenRefresh(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (_isRefreshing) {
      return handler.reject(error);
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorageService.read(
        key: 'refresh_token',
      );

      if (refreshToken == null || refreshToken.isEmpty) {
        // No refresh token available, logout user
        await _logoutUser();
        _isRefreshing = false;
        return handler.reject(error);
      }

      // Attempt to refresh the access token
      final newAccessToken = await _refreshAccessToken(refreshToken);

      if (newAccessToken.isNotEmpty) {
        // Update the token in storage
        await _secureStorageService.write(
          key: AppConstants.tokenKey,
          value: newAccessToken,
        );

        // Update the original request with new token
        error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        // Retry the original request
        _isRefreshing = false;
        try {
          final response = await _dio.request<dynamic>(
            error.requestOptions.path,
            data: error.requestOptions.data,
            queryParameters: error.requestOptions.queryParameters,
            options: Options(
              method: error.requestOptions.method,
              headers: error.requestOptions.headers,
            ),
          );
          return handler.resolve(response);
        } catch (e) {
          return handler.reject(error);
        }
      } else {
        // Failed to get new token, logout user
        await _logoutUser();
        _isRefreshing = false;
        return handler.reject(error);
      }
    } catch (e) {
      // Error during refresh, logout user
      await _logoutUser();
      _isRefreshing = false;
      return handler.reject(error);
    }
  }

  Future<String> _refreshAccessToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['access_token'] ?? data['accessToken'] ?? '';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  Future<void> _logoutUser() async {
    try {
      // Clear tokens from storage
      await _secureStorageService.delete(key: AppConstants.tokenKey);
      await _secureStorageService.delete(key: 'refresh_token');
      await _secureStorageService.delete(key: 'user_data');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error during logout: $e');
      }
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
