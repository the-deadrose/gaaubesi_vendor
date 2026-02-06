import 'package:equatable/equatable.dart';

class CreateStaffState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateStaffInitial extends CreateStaffState {}

class CreateStaffLoading extends CreateStaffState {}

class CreateStaffSuccess extends CreateStaffState {
  final String message;

  CreateStaffSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class CreateStaffFailure extends CreateStaffState {
  final String error;

  CreateStaffFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class CreateStaffReset extends CreateStaffState {}
