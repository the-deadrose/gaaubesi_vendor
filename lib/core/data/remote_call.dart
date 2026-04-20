import 'package:dio/dio.dart';
import 'package:gaaubesi_vendor/core/network/dio_exception_mapper.dart';

/// Wraps a Dio request so every datasource surfaces the same typed exceptions.
///
/// The `parse` callback is where datasources turn the raw [Response] into
/// their model. Any [DioException] thrown by the request is mapped to a
/// typed domain exception via [mapDioException]; other throws bubble up.
Future<T> remoteCall<T>(
  Future<Response> Function() request,
  T Function(Response response) parse,
) async {
  try {
    final response = await request();
    return parse(response);
  } on DioException catch (e) {
    throw mapDioException(e);
  }
}
