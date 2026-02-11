import 'package:equatable/equatable.dart';

abstract class TodayDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchTodayDetailEvent extends TodayDetailEvent {
  final String status;

  FetchTodayDetailEvent({required this.status});

  @override
  List<Object?> get props => [status];
}

class RefreshTodayDetailEvent extends TodayDetailEvent {
  final String status;

  RefreshTodayDetailEvent({required this.status});

  @override
  List<Object?> get props => [status];
}
