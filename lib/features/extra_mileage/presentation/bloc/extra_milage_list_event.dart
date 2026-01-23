import 'package:equatable/equatable.dart';

abstract class ExtraMileageEvent extends Equatable {
  const ExtraMileageEvent();

  @override
  List<Object?> get props => [];
}

class FetchExtraMileageListEvent extends ExtraMileageEvent {
  final String status;
  final String startDate;
  final String endDate;

  const FetchExtraMileageListEvent({
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [status, startDate, endDate];
}

class LoadMoreExtraMileageEvent extends ExtraMileageEvent {
  const LoadMoreExtraMileageEvent();
}

class RefreshExtraMileageListEvent extends ExtraMileageEvent {
  final String status;
  final String startDate;
  final String endDate;

  const RefreshExtraMileageListEvent({
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [status, startDate, endDate];
}
