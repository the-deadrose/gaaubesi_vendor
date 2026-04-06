import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String? get(String key) {
    return dotenv.env[key];
  }

  static String getOrThrow(String key) {
    final value = dotenv.env[key];
    if (value == null) {
      throw Exception('Missing environment variable: $key');
    }
    return value;
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  static int getInt(String key, {int defaultValue = 0}) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  static String getEnvironment() {
    return const String.fromEnvironment('ENVIRONMENT', defaultValue: 'local');
  }
}
