// Environment configuration - set via --dart-define=ENV=local/staging/production
const String _env = String.fromEnvironment('ENV', defaultValue: 'local');

// Base URLs for different environments
const Map<String, String> _baseUrls = {
  'local': 'http://192.168.100.181:8000/api/v3/vendor',
  'staging': 'https://staging-api.example.com/api/v3/vendor',
  'production': 'https://api.example.com/api/v3/vendor',
};

class AppConstants {
  static String get baseUrl => _baseUrls[_env] ?? _baseUrls['local']!;
  static const String tokenKey = 'auth_token';
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  static String get environment => _env;
}
