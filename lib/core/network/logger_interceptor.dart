import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggerInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 75,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i('REQUEST[${options.method}] => PATH: ${options.path}');
    _logger.d('Headers: ${options.headers}');
    if (options.data != null) {
      _logger.d('Body: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    _logger.d('Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      error: err.error,
      stackTrace: err.stackTrace,
    );
    if (err.response != null) {
      final errorData = err.response?.data;
      if (errorData is Map<String, dynamic>) {
        _logger.e(
          'Error Response: {success: false, message: ${errorData['message'] ?? err.message}, data: null}',
        );
      } else {
        _logger.e('Error Data: $errorData');
      }
    }
    super.onError(err, handler);
  }
}
