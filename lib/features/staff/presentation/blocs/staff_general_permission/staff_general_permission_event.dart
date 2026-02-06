import 'package:equatable/equatable.dart';

abstract class StaffGeneralPermissionEvent extends Equatable {
  const StaffGeneralPermissionEvent();

  @override
  List<Object?> get props => [];
}

class FetchGeneralPermissions extends StaffGeneralPermissionEvent {
  final String userId;

  const FetchGeneralPermissions({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class RefreshGeneralPermissions extends StaffGeneralPermissionEvent {
  final String userId;

  const RefreshGeneralPermissions({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateGeneralPermissions extends StaffGeneralPermissionEvent {
  final String userId;
  final List<int> permissionIds;

  const UpdateGeneralPermissions({
    required this.userId,
    required this.permissionIds,
  });

  @override
  List<Object?> get props => [userId, permissionIds];
}
