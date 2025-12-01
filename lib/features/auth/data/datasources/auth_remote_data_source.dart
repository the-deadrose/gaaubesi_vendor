import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _dioClient.post(
        '/login/',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        // Assuming the API returns { "user": { ... }, "token": "..." }
        // Or just the user object. Adjust based on actual API.
        // For this example, let's assume the response data IS the user object.
        return UserModel.fromJson(response.data);
      } else {
        throw ServerException('Login failed');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Unknown error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
