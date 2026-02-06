import 'package:equatable/equatable.dart';

abstract class StaffExtraMileagePermissionEvent extends Equatable {
  const StaffExtraMileagePermissionEvent();

  @override
  List<Object?> get props => [];
}

class FetchExtraMileagePermissions extends StaffExtraMileagePermissionEvent {
  final String userId;

  const FetchExtraMileagePermissions({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class RefreshExtraMileagePermissions extends StaffExtraMileagePermissionEvent {
  final String userId;

  const RefreshExtraMileagePermissions({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateExtraMileagePermissions extends StaffExtraMileagePermissionEvent {
  final String userId;
  final List<int> permissionIds;

  const UpdateExtraMileagePermissions({
    required this.userId,
    required this.permissionIds,
  });

  @override
  List<Object?> get props => [userId, permissionIds];
}
