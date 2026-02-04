import 'package:equatable/equatable.dart';

abstract class PickupOrderAnalysisEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchPickupOrderAnalysisEvent extends PickupOrderAnalysisEvent {
  final String startDate;
  final String endDate;

  FetchPickupOrderAnalysisEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class ResetPickupOrderAnalysisEvent extends PickupOrderAnalysisEvent {}
