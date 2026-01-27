import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/constants/constants.dart';
import 'package:gaaubesi_vendor/core/di/injection.dart';
import 'package:gaaubesi_vendor/core/network/logger_interceptor.dart';
import 'package:gaaubesi_vendor/core/services/secure_storage_service.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_event.dart';

@lazySingleton
class DioClient {
  final Dio _dio;
  final SecureStorageService _secureStorageService;
  bool _isRefreshing = false;
  final List<Function> _refreshCallbacks = [];

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
                // Check if token is expired before making request
                try {
                  final isExpired = JwtDecoder.isExpired(token);
                  if (isExpired) {
                    debugPrint('⚠️  [DioClient] Access token expired, will refresh');
                  }
                } catch (e) {
                  debugPrint('⚠️  [DioClient] Failed to decode JWT: $e');
                }
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

            // If refresh token is invalid/expired, logout user and don't propagate error
            if (e.response?.statusCode == 401 &&
                e.requestOptions.path == ApiEndpoints.refreshToken) {
              debugPrint('🚪 [DioClient] Refresh token expired, logging out user');
              await _logoutUser();
              // Return cancelled error to prevent error screens from showing
              // The BlocListener will handle navigation to login
              return handler.reject(
                DioException(
                  requestOptions: e.requestOptions,
                  type: DioExceptionType.cancel,
                  error: 'Session expired. Please login again.',
                ),
              );
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
    debugPrint('🔄 [DioClient] Handling 401 - Token refresh needed');
    
    // If already refreshing, queue this request
    if (_isRefreshing) {
      debugPrint('⏳ [DioClient] Already refreshing, queuing request');
      final completer = Completer<Response>();
      _refreshCallbacks.add((newToken) {
        if (newToken != null) {
          // Retry with new token
          error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          _dio.request<dynamic>(
            error.requestOptions.path,
            data: error.requestOptions.data,
            queryParameters: error.requestOptions.queryParameters,
            options: Options(
              method: error.requestOptions.method,
              headers: error.requestOptions.headers,
            ),
          ).then(completer.complete).catchError(completer.completeError);
        } else {
          completer.completeError(error);
        }
      });
      
      try {
        final response = await completer.future;
        return handler.resolve(response);
      } catch (e) {
        return handler.reject(error);
      }
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorageService.read(
        key: 'refresh_token',
      );

      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('❌ [DioClient] No refresh token available');
        await _logoutUser();
        _isRefreshing = false;
        _notifyRefreshCallbacks(null);
        // Return cancelled error to prevent error screens
        return handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            type: DioExceptionType.cancel,
            error: 'Session expired. Please login again.',
          ),
        );
      }

      // Check if refresh token is expired
      try {
        final isRefreshExpired = JwtDecoder.isExpired(refreshToken);
        if (isRefreshExpired) {
          debugPrint('❌ [DioClient] Refresh token is expired');
          await _logoutUser();
          _isRefreshing = false;
          _notifyRefreshCallbacks(null);
          // Return cancelled error to prevent error screens
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              type: DioExceptionType.cancel,
              error: 'Session expired. Please login again.',
            ),
          );
        }
      } catch (e) {
        debugPrint('⚠️  [DioClient] Failed to decode refresh token: $e');
      }

      debugPrint('🔄 [DioClient] Attempting to refresh access token...');
      // Attempt to refresh the access token
      final newAccessToken = await _refreshAccessToken(refreshToken);

      if (newAccessToken.isNotEmpty) {
        debugPrint('✅ [DioClient] Successfully refreshed access token');
        
        // Update the token in storage
        await _secureStorageService.write(
          key: AppConstants.tokenKey,
          value: newAccessToken,
        );

        // Update the original request with new token
        error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        // Notify queued requests
        _notifyRefreshCallbacks(newAccessToken);
        _isRefreshing = false;
        
        // Retry the original request
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
          debugPrint('❌ [DioClient] Failed to retry request after refresh: $e');
          return handler.reject(error);
        }
      } else {
        debugPrint('❌ [DioClient] Failed to refresh token');
        // Failed to get new token, logout user
        await _logoutUser();
        _notifyRefreshCallbacks(null);
        _isRefreshing = false;
        // Return cancelled error to prevent error screens
        return handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            type: DioExceptionType.cancel,
            error: 'Session expired. Please login again.',
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ [DioClient] Error during token refresh: $e');
      // Error during refresh, logout user
      await _logoutUser();
      _notifyRefreshCallbacks(null);
      _isRefreshing = false;
      // Return cancelled error to prevent error screens
      return handler.reject(
        DioException(
          requestOptions: error.requestOptions,
          type: DioExceptionType.cancel,
          error: 'Session expired. Please login again.',
        ),
      );
    }
  }

  void _notifyRefreshCallbacks(String? newToken) {
    for (final callback in _refreshCallbacks) {
      callback(newToken);
    }
    _refreshCallbacks.clear();
  }

  Future<String> _refreshAccessToken(String refreshToken) async {
    try {
      debugPrint('📡 [DioClient] Calling refresh token API...');
      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {
          'refresh': refreshToken,  // Django typically uses 'refresh' field
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('✅ [DioClient] Refresh token API successful');
        
        // Try multiple possible field names for the new access token
        final newToken = data['access'] ?? 
                        data['access_token'] ?? 
                        data['accessToken'] ?? 
                        '';
        
        if (newToken.isNotEmpty) {
          debugPrint('✅ [DioClient] New access token received (length: ${(newToken as String).length})');
          
          // If a new refresh token is provided, update it too
          final newRefreshToken = data['refresh'] ?? 
                                 data['refresh_token'] ?? 
                                 data['refreshToken'];
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await _secureStorageService.write(
              key: 'refresh_token',
              value: newRefreshToken,
            );
            debugPrint('✅ [DioClient] New refresh token also updated');
          }
        }
        
        return newToken;
      }
      debugPrint('❌ [DioClient] Refresh token API returned status: ${response.statusCode}');
      return '';
    } on DioException catch (e) {
      debugPrint('❌ [DioClient] DioException during refresh: ${e.message}');
      debugPrint('   Status: ${e.response?.statusCode}');
      debugPrint('   Data: ${e.response?.data}');
      return '';
    } catch (e) {
      debugPrint('❌ [DioClient] Unexpected error during refresh: $e');
      return '';
    }
  }

  Future<void> _logoutUser() async {
    try {
      debugPrint('🚪 [DioClient] Logging out user - clearing all tokens');
      
      // Clear tokens from storage
      await _secureStorageService.delete(key: AppConstants.tokenKey);
      await _secureStorageService.delete(key: 'refresh_token');
      await _secureStorageService.delete(key: 'user_data');
      
      debugPrint('✅ [DioClient] All tokens cleared successfully');
      
      // Trigger AuthBloc logout to update UI state and navigate to login
      try {
        final authBloc = getIt<AuthBloc>();
        authBloc.add(AuthLogoutRequested());
        debugPrint('✅ [DioClient] AuthBloc logout event triggered');
      } catch (e) {
        debugPrint('⚠️  [DioClient] Failed to trigger AuthBloc logout: $e');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [DioClient] Error during logout: $e');
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

  //patch method
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch(
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
