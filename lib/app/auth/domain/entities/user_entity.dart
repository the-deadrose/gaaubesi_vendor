import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String token;
  final String name;
  final bool warehousePermission;

  const UserEntity({
    required this.token,
    required this.name,
    required this.warehousePermission,
  });

  @override
  List<Object?> get props => [token, name, warehousePermission];
}
