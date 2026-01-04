import 'package:equatable/equatable.dart';

abstract class RtvOrderEvent extends Equatable {
  const RtvOrderEvent();

  @override
  List<Object?> get props => [];
}

class RtvOrderLoadRequested extends RtvOrderEvent {
  const RtvOrderLoadRequested();
}

class RtvOrderRefreshRequested extends RtvOrderEvent {
  const RtvOrderRefreshRequested();
}

class RtvOrderLoadMoreRequested extends RtvOrderEvent {
  const RtvOrderLoadMoreRequested();
}

class RtvOrderFilterChanged extends RtvOrderEvent {
  final String? destination;
  final String? startDate;
  final String? endDate;
  final String? receiverSearch;
  final double? minCharge;
  final double? maxCharge;

  const RtvOrderFilterChanged({
    this.destination,
    this.startDate,
    this.endDate,
    this.receiverSearch,
    this.minCharge,
    this.maxCharge,
  });

  @override
  List<Object?> get props => [
    destination,
    startDate,
    endDate,
    receiverSearch,
    minCharge,
    maxCharge,
  ];
}
