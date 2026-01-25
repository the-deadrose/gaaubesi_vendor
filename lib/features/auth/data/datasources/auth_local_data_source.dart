import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/constants/constants.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel> getUser();
  Future<void> clearUser();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> updateAccessToken(String accessToken);
  Future<void> updateRefreshToken(String refreshToken);

}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;
  static const String _userKey = 'user_data';

  AuthLocalDataSourceImpl(this._secureStorage);

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      debugPrint(
        '💾 [AuthLocalDataSource] Saving user data for: ${user.userId}',
      );

      // Save user data as JSON
      final jsonString = json.encode(user.toJson());
      await _secureStorage.write(key: _userKey, value: jsonString);
      debugPrint('✅ [AuthLocalDataSource] User data saved');

      // Also save the access token separately for API authentication
      await _secureStorage.write(
        key: AppConstants.tokenKey,
        value: user.accessToken,
      );
      debugPrint(
        '✅ [AuthLocalDataSource] Access token saved (length: ${user.accessToken.length})',
      );

      // Save refresh token separately for token refresh logic
      await _secureStorage.write(
        key: 'refresh_token',
        value: user.refreshToken,
      );
      debugPrint(
        '✅ [AuthLocalDataSource] Refresh token saved (length: ${user.refreshToken.length})',
      );
    } catch (e) {
      debugPrint('❌ [AuthLocalDataSource] Failed to save user data: $e');
      throw CacheException('Failed to save user data');
    }
  }

  @override
  Future<UserModel> getUser() async {
    try {
      final jsonString = await _secureStorage.read(key: _userKey);
      if (jsonString != null) {
        final user = UserModel.fromJson(json.decode(jsonString));
        // Sync tokens to ensure DioClient can find them
        await _secureStorage.write(
          key: AppConstants.tokenKey,
          value: user.accessToken,
        );
        await _secureStorage.write(
          key: 'refresh_token',
          value: user.refreshToken,
        );
        return user;
      } else {
        throw CacheException('No user data found');
      }
    } catch (e) {
      throw CacheException('Failed to get user data');
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await _secureStorage.delete(key: _userKey);
      // Also clear the tokens
      await _secureStorage.delete(key: AppConstants.tokenKey);
      await _secureStorage.delete(key: 'refresh_token');
    } catch (e) {
      throw CacheException('Failed to clear user data');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.tokenKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: 'refresh_token');
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateAccessToken(String accessToken) async {
    try {
      await _secureStorage.write(
        key: AppConstants.tokenKey,
        value: accessToken,
      );
    } catch (e) {
      throw CacheException('Failed to update access token');
    }
  }

  @override
  Future<void> updateRefreshToken(String refreshToken) async {
    try {
      await _secureStorage.write(key: 'refresh_token', value: refreshToken);
    } catch (e) {
      throw CacheException('Failed to update refresh token');
    }
  }

 
}
