import 'package:equatable/equatable.dart';

abstract class StaffOrderPermissionEvent extends Equatable {
  const StaffOrderPermissionEvent();

  @override
  List<Object?> get props => [];
}

class FetchOrderPermissions extends StaffOrderPermissionEvent {
  final String userId;

  const FetchOrderPermissions({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class RefreshOrderPermissions extends StaffOrderPermissionEvent {
  final String userId;

  const RefreshOrderPermissions({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateOrderPermissions extends StaffOrderPermissionEvent {
  final String userId;
  final List<int> permissionIds;

  const UpdateOrderPermissions({
    required this.userId,
    required this.permissionIds,
  });

  @override
  List<Object?> get props => [userId, permissionIds];
}
