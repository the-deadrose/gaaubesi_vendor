import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/staff/domain/usecase/edit_staff_info_usecase.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/edit_info/edit_staff_info_event.dart';
import 'package:gaaubesi_vendor/features/staff/presentation/blocs/edit_info/edit_staff_info_state.dart';

class EditStaffInfoBloc extends Bloc<EditStaffInfoEvent, EditStaffInfoState> {
  final EditStaffInfoUsecase _editStaffInfoUsecase;

  EditStaffInfoBloc({required EditStaffInfoUsecase editStaffInfoUsecase})
    : _editStaffInfoUsecase = editStaffInfoUsecase,
      super(EditStaffInfoInitial()) {
    on<EditStaffInfoSubmitted>(_onEditStaffInfoSubmitted);
    on<EditStaffInfoReset>(_onEditStaffInfoReset);
  }

  Future<void> _onEditStaffInfoSubmitted(
    EditStaffInfoSubmitted event,
    Emitter<EditStaffInfoState> emit,
  ) async {
    emit(EditStaffInfoLoading());
    if (event.fullName.isEmpty ||
        event.email.isEmpty ||
        event.phone.isEmpty ||
        event.userName.isEmpty) {
      emit(EditStaffInfoFailure(error: 'All fields are required'));
      return;
    }
    if (!_isValidEmail(event.email)) {
      emit(EditStaffInfoFailure(error: 'Please enter a valid email address'));
      return;
    }
    if (!_isValidPhone(event.phone)) {
      emit(EditStaffInfoFailure(error: 'Please enter a valid phone number'));
      return;
    }

    final result = await _editStaffInfoUsecase(
      EditStaffInfoUsecaseParams(
        userId: event.userId,
        fullName: event.fullName,
        email: event.email,
        phone: event.phone,
        userName: event.userName,
      ),
    );

    result.fold(
      (failure) {
        emit(EditStaffInfoFailure(error: failure.toString()));
      },
      (_) {
        emit(
          EditStaffInfoSuccess(
            message: 'Staff information updated successfully',
          ),
        );
      },
    );
  }

  void _onEditStaffInfoReset(
    EditStaffInfoReset event,
    Emitter<EditStaffInfoState> emit,
  ) {
    emit(EditStaffInfoResetState());
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone);
  }
}
