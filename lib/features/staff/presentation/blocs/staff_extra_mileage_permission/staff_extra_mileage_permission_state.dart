import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/staff/domain/entity/staff_available_permission_entity.dart';

class StaffExtraMileagePermissionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StaffExtraMileagePermissionInitial
    extends StaffExtraMileagePermissionState {}

class StaffExtraMileagePermissionLoading
    extends StaffExtraMileagePermissionState {}

class StaffExtraMileagePermissionLoaded extends StaffExtraMileagePermissionState {
  final StaffAvailablePermissionEntity permissions;

  StaffExtraMileagePermissionLoaded({required this.permissions});

  @override
  List<Object?> get props => [permissions];
}

class StaffExtraMileagePermissionError extends StaffExtraMileagePermissionState {
  final String message;

  StaffExtraMileagePermissionError({required this.message});

  @override
  List<Object?> get props => [message];
}

class StaffExtraMileagePermissionEmpty extends StaffExtraMileagePermissionState {}

class StaffExtraMileagePermissionUpdating
    extends StaffExtraMileagePermissionState {}

class StaffExtraMileagePermissionUpdateSuccess
    extends StaffExtraMileagePermissionState {
  final String message;

  StaffExtraMileagePermissionUpdateSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class StaffExtraMileagePermissionUpdateError
    extends StaffExtraMileagePermissionState {
  final String message;

  StaffExtraMileagePermissionUpdateError({required this.message});

  @override
  List<Object?> get props => [message];
}
