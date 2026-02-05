import 'package:equatable/equatable.dart';

class StaffListEntity extends Equatable {
  final bool success;
  final String message;
  final List<StaffEntity> data;

  const StaffListEntity({
    required this.success,
    required this.message,
    required this.data,
  });

  @override
  List<Object?> get props => [success, message, data];
}

class StaffEntity extends Equatable {
  final int id;
  final String fullName;
  final String username;
  final String email;
  final String phoneNumber;
  final String role;

  const StaffEntity({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.role,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        username,
        email,
        phoneNumber,
        role,
      ];
}

class PermissionEntity extends Equatable {
  final int id;
  final String name;

  const PermissionEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
