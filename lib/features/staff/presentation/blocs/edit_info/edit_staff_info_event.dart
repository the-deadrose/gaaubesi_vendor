import 'package:equatable/equatable.dart';

abstract class EditStaffInfoEvent extends Equatable{
  @override
  List<Object?> get props => [];
}

class EditStaffInfoSubmitted extends EditStaffInfoEvent {
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String userName;

  EditStaffInfoSubmitted({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.userName,
  });

  @override
  List<Object?> get props => [userId, fullName, email, phone, userName];
}

class EditStaffInfoReset extends EditStaffInfoEvent {}