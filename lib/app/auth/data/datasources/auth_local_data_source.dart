import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/constants/constants.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/app/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel> getUser();
  Future<void> clearUser();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;
  static const String _userKey = 'user_data';

  AuthLocalDataSourceImpl(this._secureStorage);

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      // Save user data as JSON
      final jsonString = json.encode(user.toJson());
      await _secureStorage.write(key: _userKey, value: jsonString);

      // Also save the token separately for API authentication
      await _secureStorage.write(key: AppConstants.tokenKey, value: user.token);
    } catch (e) {
      throw CacheException('Failed to save user data');
    }
  }

  @override
  Future<UserModel> getUser() async {
    try {
      final jsonString = await _secureStorage.read(key: _userKey);
      if (jsonString != null) {
        final user = UserModel.fromJson(json.decode(jsonString));
        // Sync token to ensure DioClient can find it (migration for existing sessions)
        await _secureStorage.write(
          key: AppConstants.tokenKey,
          value: user.token,
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
      // Also clear the token
      await _secureStorage.delete(key: AppConstants.tokenKey);
    } catch (e) {
      throw CacheException('Failed to clear user data');
    }
  }
}
