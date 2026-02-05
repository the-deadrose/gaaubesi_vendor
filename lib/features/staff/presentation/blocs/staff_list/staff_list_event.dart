import 'package:equatable/equatable.dart';

abstract class StaffListEvent extends Equatable {
  const StaffListEvent();

  @override
  List<Object?> get props => [];
}

class FetchStaffListEvent extends StaffListEvent {
  const FetchStaffListEvent();

  @override
  List<Object?> get props => [];
}

class RefreshStaffListEvent extends StaffListEvent {
  const RefreshStaffListEvent();

  @override
  List<Object?> get props => [];
}
