import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:gaaubesi_vendor/configure/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/configure/constants/constants.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/core/network/connectivity_service.dart';
import 'package:gaaubesi_vendor/core/network/dio_exception_mapper.dart';
import 'package:gaaubesi_vendor/core/network/logger_interceptor.dart';
import 'package:gaaubesi_vendor/core/network/session_handler.dart';
import 'package:gaaubesi_vendor/core/services/secure_storage_service.dart';

@lazySingleton
class DioClient {
  final Dio _dio;
  final SecureStorageService _secureStorageService;
  final SessionHandler _sessionHandler;
  final ConnectivityService _connectivity;

  /// Single in-flight refresh. Completes with a new access token, or `null`
  /// if refresh failed (caller should treat the request as unauthorized).
  Completer<String?>? _refreshCompleter;

  DioClient(
    this._dio,
    this._secureStorageService,
    this._sessionHandler,
    this._connectivity,
  ) {
    _dio
      ..options.baseUrl = AppConstants.baseUrl
      ..options.connectTimeout =
          Duration(milliseconds: AppConstants.connectTimeout)
      ..options.receiveTimeout =
          Duration(milliseconds: AppConstants.receiveTimeout)
      ..options.responseType = ResponseType.json
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: _onRequest,
          onError: _onError,
        ),
      );

    if (kDebugMode) {
      _dio.interceptors.add(LoggerInterceptor());
    }
  }

  Dio get dio => _dio;

  // ────────────────────────── Interceptor handlers ──────────────────────────

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Short-circuit obvious offline state so the user gets instant feedback
    // instead of a 30-second connect timeout.
    if (!await _connectivity.hasConnection) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: NetworkException('No internet connection'),
        ),
      );
    }

    if (!_isAuthEndpoint(options.path)) {
      final token =
          await _secureStorageService.read(key: AppConstants.tokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  Future<void> _onError(
    DioException e,
    ErrorInterceptorHandler handler,
  ) async {
    final status = e.response?.statusCode;
    final path = e.requestOptions.path;

    // 401 on a protected endpoint → try to refresh once and replay.
    if (status == 401 && !_isAuthEndpoint(path)) {
      return _handleUnauthorized(e, handler);
    }

    // Everything else: map to a typed domain exception and forward.
    final mapped = mapDioException(e);
    if (mapped is DioException) {
      return handler.next(mapped);
    }
    return handler.reject(
      DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        type: e.type,
        error: mapped,
        message: _messageOf(mapped) ?? e.message,
      ),
    );
  }

  // ───────────────────────────── Refresh flow ──────────────────────────────

  Future<void> _handleUnauthorized(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final newToken = await _acquireFreshToken();

    if (newToken == null) {
      // Refresh failed — surface as unauthorized and kick off session cleanup.
      await _sessionHandler.onUnauthorized();
      return handler.reject(
        DioException(
          requestOptions: error.requestOptions,
          response: error.response,
          type: DioExceptionType.cancel,
          error: UnauthorizedException('Session expired. Please log in again.'),
          message: 'Session expired. Please log in again.',
        ),
      );
    }

    // Retry the original request with the fresh token.
    try {
      final retryOptions = error.requestOptions
        ..headers['Authorization'] = 'Bearer $newToken';
      final response = await _dio.fetch<dynamic>(retryOptions);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      // Propagate the *real* retry failure, not the stale 401.
      final mapped = mapDioException(retryError);
      if (mapped is DioException) {
        return handler.next(mapped);
      }
      return handler.reject(
        DioException(
          requestOptions: retryError.requestOptions,
          response: retryError.response,
          type: retryError.type,
          error: mapped,
          message: _messageOf(mapped) ?? retryError.message,
        ),
      );
    }
  }

  /// Returns a fresh access token, coalescing concurrent callers onto a
  /// single refresh request. Returns `null` if refresh is not possible.
  Future<String?> _acquireFreshToken() {
    final existing = _refreshCompleter;
    if (existing != null) return existing.future;

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    _runRefresh().then((token) {
      if (!completer.isCompleted) completer.complete(token);
    }).catchError((Object error) {
      if (!completer.isCompleted) completer.complete(null);
    }).whenComplete(() {
      _refreshCompleter = null;
    });

    return completer.future;
  }

  Future<String?> _runRefresh() async {
    final refreshToken =
        await _secureStorageService.read(key: 'refresh_token');
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      if (JwtDecoder.isExpired(refreshToken)) return null;
    } catch (_) {
      // Token isn't a JWT we can decode — let the server reject it.
    }

    try {
      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode != 200 || response.data is! Map) return null;

      final data = response.data as Map<String, dynamic>;
      final newAccess = (data['access'] ??
              data['access_token'] ??
              data['accessToken'] ??
              '') as String;
      if (newAccess.isEmpty) return null;

      await _secureStorageService.write(
        key: AppConstants.tokenKey,
        value: newAccess,
      );

      final newRefresh = data['refresh'] ??
          data['refresh_token'] ??
          data['refreshToken'];
      if (newRefresh is String && newRefresh.isNotEmpty) {
        await _secureStorageService.write(
          key: 'refresh_token',
          value: newRefresh,
        );
      }

      return newAccess;
    } on DioException {
      return null;
    }
  }

  // ───────────────────────────── Helpers ──────────────────────────────

  bool _isAuthEndpoint(String path) {
    return path == ApiEndpoints.login ||
        path == ApiEndpoints.refreshToken ||
        path.contains('/register');
  }

  String? _messageOf(Object e) {
    if (e is ServerException) return e.message;
    if (e is UnauthorizedException) return e.message;
    if (e is ValidationException) return e.message;
    if (e is NetworkException) return e.message;
    if (e is CacheException) return e.message;
    return null;
  }

  // ───────────────────────── Thin request facade ───────────────────────────

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get(path, queryParameters: queryParameters, options: options);

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.post(path,
          data: data, queryParameters: queryParameters, options: options);

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.put(path,
          data: data, queryParameters: queryParameters, options: options);

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.patch(path,
          data: data, queryParameters: queryParameters, options: options);

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.delete(path,
          data: data, queryParameters: queryParameters, options: options);
}
