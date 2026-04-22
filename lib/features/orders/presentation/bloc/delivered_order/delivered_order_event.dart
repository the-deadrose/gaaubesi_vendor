import 'package:equatable/equatable.dart';

abstract class DeliveredOrderEvent extends Equatable {
  const DeliveredOrderEvent();

  @override
  List<Object?> get props => [];
}

class DeliveredOrderLoadRequested extends DeliveredOrderEvent {
  const DeliveredOrderLoadRequested();
}

class DeliveredOrderRefreshRequested extends DeliveredOrderEvent {
  const DeliveredOrderRefreshRequested();
}

class DeliveredOrderLoadMoreRequested extends DeliveredOrderEvent {
  const DeliveredOrderLoadMoreRequested();
}

class DeliveredOrderFilterChanged extends DeliveredOrderEvent {
  final String? destination;
  final String? startDate;
  final String? endDate;
  final String? receiverSearch;

  const DeliveredOrderFilterChanged({
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
