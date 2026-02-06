import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/staff/domain/usecase/create_staff_usecase.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/create_staff/create_staff_event.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/create_staff/create_staff_state.dart';
import 'package:injectable/injectable.dart';


@lazySingleton

class CreateStaffBloc extends Bloc<CreateStaffEvent, CreateStaffState> {
  final CreateStaffUsecase _createStaffUsecase;

  CreateStaffBloc(this._createStaffUsecase) : super(CreateStaffInitial()) {
    on<CreateStaff>(_onCreateStaff);
    on<ResetCreateStaffState>(_onResetState);
  }

  Future<void> _onCreateStaff(
    CreateStaff event,
    Emitter<CreateStaffState> emit,
  ) async {
    emit(CreateStaffLoading());

    final result = await _createStaffUsecase(
      CreateStaffUsecaseParams(
        fullName: event.fullName,
        email: event.email,
        phoneNumber: event.phoneNumber,
        userName: event.userName,
        password: event.password,
        confirmPassword: event.confirmPassword,
      ),
    );

    result.fold(
      (failure) {
        emit(CreateStaffFailure(error: failure.message));
      },
      (_) {
        emit(CreateStaffSuccess(message: 'Staff created successfully'));
      },
    );
  }

  void _onResetState(
    ResetCreateStaffState event,
    Emitter<CreateStaffState> emit,
  ) {
    emit(CreateStaffInitial());
  }
}
