import 'package:equatable/equatable.dart';

abstract class CreateStaffEvent extends Equatable{
  @override
  List<Object?> get props => [];
}

class CreateStaff extends CreateStaffEvent{
  final String fullName;
  final String email;
  final String phoneNumber;
  final String userName;
  final String password;
  final String confirmPassword;

  CreateStaff({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.userName,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [
    fullName,
    email,
    phoneNumber,
    userName,
    password,
    confirmPassword,
  ];
}

class ResetCreateStaffState extends CreateStaffEvent{}