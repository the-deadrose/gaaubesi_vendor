import 'package:equatable/equatable.dart';

class EditStaffInfoState extends Equatable{
  @override
  List<Object?> get props => [];
}

class EditStaffInfoInitial extends EditStaffInfoState {}

class EditStaffInfoLoading extends EditStaffInfoState {}

class EditStaffInfoSuccess extends EditStaffInfoState {
  final String message;
  EditStaffInfoSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}


class EditStaffInfoFailure extends EditStaffInfoState {
  final String error;
  EditStaffInfoFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class EditStaffInfoResetState extends EditStaffInfoState {}
