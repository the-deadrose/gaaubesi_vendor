import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:gaaubesi_vendor/core/presentation/utils/snackbar.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/auth/domain/usecases/change_password_usecase.dart';
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
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _getCurrentUserUseCase(NoParams());
    result.fold(
      (_) => emit(AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _loginUseCase(
      LoginParams(username: event.username, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.userMessage)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _logoutUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthFailure(failure.userMessage)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onChangePasswordRequested(
    ChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(ChangePasswordLoading());
    final result = await _changePasswordUsecase(
      ChangePasswordParams(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      ),
    );
    result.fold(
      (failure) => emit(ChangePasswordFailure(failure.userMessage)),
      (_) => emit(ChangePasswordSuccess('Password changed successfully')),
    );
  }
}
