import 'package:equatable/equatable.dart';

class ChangeStaffPasswordState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChangeStaffPasswordInitial extends ChangeStaffPasswordState {}

class ChangeStaffPasswordLoading extends ChangeStaffPasswordState {}

class ChangeStaffPasswordSuccess extends ChangeStaffPasswordState {
  final String message;
  ChangeStaffPasswordSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ChangeStaffPasswordFailure extends ChangeStaffPasswordState {
  final String error;
  ChangeStaffPasswordFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class ChangeStaffPasswordResetState extends ChangeStaffPasswordState {}
