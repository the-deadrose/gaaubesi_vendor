import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/staff/domain/entity/staff_list_entity.dart';

class StaffListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StaffListInitial extends StaffListState {}

class StaffListLoading extends StaffListState {}

class StaffListLoaded extends StaffListState {
  final StaffListEntity staffListEntity;

  StaffListLoaded({required this.staffListEntity});

  @override
  List<Object?> get props => [staffListEntity];
}

class StaffListError extends StaffListState {
  final String message;

  StaffListError({required this.message});

  @override
  List<Object?> get props => [message];
}

class StaffListEmpty extends StaffListState {}
