import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/staff/domain/usecase/change_password_staff_usecase.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/change_password/change_staff_password_event.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/change_password/change_staff_password_state.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ChangeStaffPasswordBloc
    extends Bloc<ChangeStaffPasswordEvent, ChangeStaffPasswordState> {
  final ChangePasswordStaffUsecase _changePasswordStaffUsecase;

  ChangeStaffPasswordBloc({
    required ChangePasswordStaffUsecase changePasswordStaffUsecase,
  }) : _changePasswordStaffUsecase = changePasswordStaffUsecase,
       super(ChangeStaffPasswordInitial()) {
    on<ChangePasswordSubmitted>(_onChangePasswordSubmitted);
    on<ChangePasswordReset>(_onChangePasswordReset);
  }

  Future<void> _onChangePasswordSubmitted(
    ChangePasswordSubmitted event,
    Emitter<ChangeStaffPasswordState> emit,
  ) async {
    emit(ChangeStaffPasswordLoading());
    if (event.newPassword != event.confirmPassword) {
      emit(ChangeStaffPasswordFailure(error: 'Passwords do not match'));
      return;
    }
    if (event.newPassword.length < 6) {
      emit(
        ChangeStaffPasswordFailure(
          error: 'Password must be at least 6 characters',
        ),
      );
      return;
    }

    final result = await _changePasswordStaffUsecase(
      ChangePasswordStaffUsecaseParams(
        userId: event.userId,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      ),
    );

    result.fold(
      (failure) {
        emit(ChangeStaffPasswordFailure(error: failure.message));
      },
      (_) {
        emit(
          ChangeStaffPasswordSuccess(message: 'Password changed successfully'),
        );
      },
    );
  }

  void _onChangePasswordReset(
    ChangePasswordReset event,
    Emitter<ChangeStaffPasswordState> emit,
  ) {
    emit(ChangeStaffPasswordResetState());
  }
}
