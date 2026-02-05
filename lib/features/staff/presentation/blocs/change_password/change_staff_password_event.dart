import 'package:equatable/equatable.dart';

abstract class ChangeStaffPasswordEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChangePasswordSubmitted extends ChangeStaffPasswordEvent {
  final String userId;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordSubmitted({
    required this.userId,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [userId, newPassword, confirmPassword];
}

class ChangePasswordReset extends ChangeStaffPasswordEvent {}
