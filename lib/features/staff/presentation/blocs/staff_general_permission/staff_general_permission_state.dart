import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/staff/domain/entity/staff_available_permission_entity.dart';

class StaffGeneralPermissionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StaffGeneralPermissionInitial extends StaffGeneralPermissionState {}

class StaffGeneralPermissionLoading extends StaffGeneralPermissionState {}

class StaffGeneralPermissionLoaded extends StaffGeneralPermissionState {
  final StaffAvailablePermissionEntity permissions;

  StaffGeneralPermissionLoaded({required this.permissions});

  @override
  List<Object?> get props => [permissions];
}

class StaffGeneralPermissionError extends StaffGeneralPermissionState {
  final String message;

  StaffGeneralPermissionError({required this.message});

  @override
  List<Object?> get props => [message];
}

class StaffGeneralPermissionEmpty extends StaffGeneralPermissionState {}

class StaffGeneralPermissionUpdating extends StaffGeneralPermissionState {}

class StaffGeneralPermissionUpdateSuccess extends StaffGeneralPermissionState {
  final String message;

  StaffGeneralPermissionUpdateSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class StaffGeneralPermissionUpdateError extends StaffGeneralPermissionState {
  final String message;

  StaffGeneralPermissionUpdateError({required this.message});

  @override
  List<Object?> get props => [message];
}
