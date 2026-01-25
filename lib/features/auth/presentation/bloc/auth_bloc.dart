import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:gaaubesi_vendor/features/auth/domain/usecases/login_usecase.dart';
import 'package:gaaubesi_vendor/features/auth/domain/usecases/logout_usecase.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_event.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_state.dart';

@singleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final ChangePasswordUsecase _changePasswordUsecase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required ChangePasswordUsecase changePasswordUsecase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _changePasswordUsecase = changePasswordUsecase,
        super(AuthInitial()) {
    // Auth events
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);

    // Change password event
    on<ChangePasswordRequested>(_onChangePasswordRequested);
  }

  // -------------------- Auth Logic --------------------
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _getCurrentUserUseCase(NoParams());

    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('🚀 [AuthBloc] Login requested for: ${event.username}');
    emit(AuthLoading());

    try {
      final result = await _loginUseCase(
        LoginParams(username: event.username, password: event.password),
      );

      result.fold(
        (failure) {
          debugPrint('❌ [AuthBloc] Login failed: ${failure.message}');
          emit(AuthFailure(failure.message));
        },
        (user) {
          debugPrint('✅ [AuthBloc] Login successful for user: ${user.userId}');
          debugPrint('👤 [AuthBloc] User role: ${user.role}, Department: ${user.department}');
          emit(AuthAuthenticated(user));
        },
      );
    } catch (e) {
      debugPrint('❌ [AuthBloc] Unexpected error during login: $e');
      emit(AuthFailure('Unexpected error: $e'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _logoutUseCase(NoParams());

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  // -------------------- Change Password Logic --------------------
  Future<void> _onChangePasswordRequested(
    ChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(ChangePasswordLoading());

    try {
      final result = await _changePasswordUsecase(
        ChangePasswordParams(
          currentPassword: event.currentPassword,
          newPassword: event.newPassword,
          confirmPassword: event.confirmPassword,
        ),
      );

      result.fold(
        (failure) {
          debugPrint('❌ [AuthBloc] Change password failed: ${failure.message}');
          emit(ChangePasswordFailure(failure.message));
        },
        (successMessage) {
          debugPrint('✅ [AuthBloc] Password changed successfully');
          emit(ChangePasswordSuccess('Password changed successfully'));
        },
      );
    } catch (e) {
      debugPrint('❌ [AuthBloc] Unexpected error during password change: $e');
      emit(ChangePasswordFailure('Unexpected error: $e'));
    }
  }
}
