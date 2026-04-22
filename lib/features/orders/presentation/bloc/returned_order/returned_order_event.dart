import 'package:equatable/equatable.dart';

abstract class ReturnedOrderEvent extends Equatable {
  const ReturnedOrderEvent();

  @override
  List<Object?> get props => [];
}

class ReturnedOrderLoadRequested extends ReturnedOrderEvent {
  const ReturnedOrderLoadRequested();
}

class ReturnedOrderRefreshRequested extends ReturnedOrderEvent {
  const ReturnedOrderRefreshRequested();
}

class ReturnedOrderLoadMoreRequested extends ReturnedOrderEvent {
  const ReturnedOrderLoadMoreRequested();
}

class ReturnedOrderFilterChanged extends ReturnedOrderEvent {
  final String? destination;
  final String? startDate;
  final String? endDate;
  final String? receiverSearch;

  const ReturnedOrderFilterChanged({
    this.destination,
    this.startDate,
    this.endDate,
    this.receiverSearch,
  });

  @override
  List<Object?> get props => [
    destination,
    startDate,
    endDate,
    receiverSearch,
  ];
}
