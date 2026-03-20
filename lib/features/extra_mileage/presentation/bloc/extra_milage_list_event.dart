import 'package:equatable/equatable.dart';

abstract class ExtraMileageEvent extends Equatable {
  const ExtraMileageEvent();

  @override
  List<Object?> get props => [];
}

class FetchExtraMileageListEvent extends ExtraMileageEvent {
  final String destination;
  final String startDate;
  final String endDate;

  const FetchExtraMileageListEvent({
    required this.destination,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [destination, startDate, endDate];
}

class LoadMoreExtraMileageEvent extends ExtraMileageEvent {
  const LoadMoreExtraMileageEvent();
}

class RefreshExtraMileageListEvent extends ExtraMileageEvent {
  final String destination;
  final String startDate;
  final String endDate;

  const RefreshExtraMileageListEvent({
    required this.destination,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [destination, startDate, endDate];
}
