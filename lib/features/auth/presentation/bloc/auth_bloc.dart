import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

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
}
