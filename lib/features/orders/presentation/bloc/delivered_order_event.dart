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
