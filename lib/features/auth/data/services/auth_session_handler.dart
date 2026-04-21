import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:gaaubesi_vendor/configure/constants/constants.dart';
import 'package:gaaubesi_vendor/core/di/injection.dart';
import 'package:gaaubesi_vendor/core/network/session_handler.dart';
import 'package:gaaubesi_vendor/core/services/secure_storage_service.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_event.dart';

/// Clears persisted credentials and signals [AuthBloc] on session loss.
///
/// Resolves [AuthBloc] lazily through the service locator to avoid a
/// construction-time cycle with [DioClient].
@LazySingleton(as: SessionHandler)
class AuthSessionHandler implements SessionHandler {
  final SecureStorageService _secureStorage;

  AuthSessionHandler(this._secureStorage);

  @override
  Future<void> onUnauthorized() async {
    await _clearTokens();
    try {
      getIt<AuthBloc>().add(AuthLogoutRequested());
    } catch (e) {
      debugPrint('AuthSessionHandler: failed to notify AuthBloc: $e');
    }
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    await _secureStorage.delete(key: 'refresh_token');
    await _secureStorage.delete(key: 'user_data');
  }
}
