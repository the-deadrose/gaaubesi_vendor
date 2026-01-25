import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
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
  Future<UserModel> login(String username, String password) async {
    try {
      debugPrint('🔐 [AuthRemoteDataSource] Login attempt for username: $username');
      
      final response = await _dioClient.post(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
      );

      debugPrint('✅ [AuthRemoteDataSource] Login response status: ${response.statusCode}');
      debugPrint('📦 [AuthRemoteDataSource] Login response data: ${response.data}');

      if (response.statusCode == 200) {
        // Assuming the API returns { "user": { ... }, "token": "..." }
        // Or just the user object. Adjust based on actual API.
        // For this example, let's assume the response data IS the user object.
        try {
          debugPrint('🔍 [AuthRemoteDataSource] Parsing JSON response...');
          debugPrint('   Keys in response: ${(response.data as Map).keys.toList()}');
          
          final user = UserModel.fromJson(response.data);
          debugPrint('✅ [AuthRemoteDataSource] User model created successfully');
          debugPrint('👤 [AuthRemoteDataSource] User ID: ${user.userId}, Role: ${user.role}');
          debugPrint('🔑 [AuthRemoteDataSource] Access Token Length: ${user.accessToken.length}');
          debugPrint('🔑 [AuthRemoteDataSource] Refresh Token Length: ${user.refreshToken.length}');
          return user;
        } catch (e) {
          debugPrint('❌ [AuthRemoteDataSource] Failed to parse user model: $e');
          debugPrint('📋 [AuthRemoteDataSource] Response data type: ${response.data.runtimeType}');
          debugPrint('📋 [AuthRemoteDataSource] Full response: ${response.data}');
          rethrow;
        }
      } else {
        final errorMsg = 'Login failed with status ${response.statusCode}';
        debugPrint('❌ [AuthRemoteDataSource] $errorMsg');
        throw ServerException(errorMsg);
      }
    } on DioException catch (e) {
      debugPrint('❌ [AuthRemoteDataSource] DioException during login');
      debugPrint('   Message: ${e.message}');
      debugPrint('   Status Code: ${e.response?.statusCode}');
      debugPrint('   Response Data: ${e.response?.data}');
      debugPrint('   Error Type: ${e.type}');
      
      throw ServerException(
        e.message ?? 'Unknown error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      debugPrint('❌ [AuthRemoteDataSource] Unexpected error during login: $e');
      debugPrint('   Error type: ${e.runtimeType}');
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<String> refreshAccessToken(String refreshToken) async {
    try {
      debugPrint('🔄 [AuthRemoteDataSource] Refreshing access token...');
      final response = await _dioClient.post(
        ApiEndpoints.refreshToken,
        data: {
          'refresh': refreshToken,  // Django JWT typically uses 'refresh' field
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('✅ [AuthRemoteDataSource] Token refresh successful');
        
        // Try multiple possible field names for the new access token
        final newToken = data['access'] ?? 
                        data['access_token'] ?? 
                        data['accessToken'] ?? 
                        '';
        
        if (newToken.isNotEmpty) {
          debugPrint('✅ [AuthRemoteDataSource] New access token received');
        }
        
        return newToken;
      } else {
        debugPrint('❌ [AuthRemoteDataSource] Token refresh failed with status: ${response.statusCode}');
        throw ServerException('Token refresh failed');
      }
    } on DioException catch (e) {
      debugPrint('❌ [AuthRemoteDataSource] DioException during token refresh');
      debugPrint('   Status: ${e.response?.statusCode}');
      debugPrint('   Message: ${e.message}');
      throw ServerException(
        e.message ?? 'Unknown error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      debugPrint('❌ [AuthRemoteDataSource] Unexpected error during token refresh: $e');
      throw ServerException('Unexpected error: $e');
    }
  }

   @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
      if (response.statusCode != 200) {
        throw CacheException('Failed to change password');
      }
    } catch (e) {
      throw CacheException('Failed to change password');
    }
  }
}