import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String refreshToken;
  final String accessToken;
  final String userId;
  final String role;
  final String fullName;
  final String department;

  const UserEntity({
    required this.refreshToken,
    required this.accessToken,
    required this.userId,
    required this.role,
    required this.fullName,
    required this.department,
  });

  @override
  List<Object?> get props => [
        refreshToken,
        accessToken,
        userId,
        role,
        fullName,
        department,
      ];

  @override
  bool get stringify => true;

  UserEntity copyWith({
    String? refreshToken,
    String? accessToken,
    String? userId,
    String? role,
    String? fullName,
    String? department,
  }) {
    return UserEntity(
      refreshToken: refreshToken ?? this.refreshToken,
      accessToken: accessToken ?? this.accessToken,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      department: department ?? this.department,
    );
  }
}