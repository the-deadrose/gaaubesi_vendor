import 'package:injectable/injectable.dart';

import 'package:gaaubesi_vendor/configure/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/data/remote_call.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart'
    show ServerException, UnauthorizedException;
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
  Future<String> refreshAccessToken(String refreshToken);
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<UserModel> login(String username, String password) {
    return remoteCall(
      () => _dioClient.post(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
      ),
      (response) {
        if (response.statusCode != 200) {
          throw ServerException(
            'Login failed',
            statusCode: response.statusCode,
          );
        }
        final user = UserModel.fromJson(response.data);
        if (user.roleField.trim().toLowerCase() != 'vendor') {
          throw UnauthorizedException('You are not a vendor');
        }
        return user;
      },
    );
  }

  @override
  Future<String> refreshAccessToken(String refreshToken) {
    return remoteCall(
      () => _dioClient.post(
        ApiEndpoints.refreshToken,
        data: {'refresh': refreshToken},
      ),
      (response) {
        if (response.statusCode != 200) {
          throw ServerException('Token refresh failed');
        }
        final data = response.data as Map<String, dynamic>;
        return (data['access'] ??
                data['access_token'] ??
                data['accessToken'] ??
                '')
            as String;
      },
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return remoteCall(
      () => _dioClient.post(
        ApiEndpoints.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      ),
      (response) {
        if (response.statusCode != 200) {
          throw ServerException(
            'Failed to change password',
            statusCode: response.statusCode,
          );
        }
      },
    );
  }
}
