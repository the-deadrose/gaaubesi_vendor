import 'package:gaaubesi_vendor/core/config/env_config.dart';

class AppConstants {
  static String get baseUrl => EnvConfig.getOrThrow('API_BASE_URL');
  static String get environment => EnvConfig.getEnvironment();
  static const String tokenKey = 'auth_token';
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}
