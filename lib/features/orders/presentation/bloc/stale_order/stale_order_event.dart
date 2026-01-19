import 'package:equatable/equatable.dart';

abstract class StaleOrderEvent extends Equatable {
  const StaleOrderEvent();

  @override
  List<Object?> get props => [];
}

class StaleOrderLoadRequested extends StaleOrderEvent {
  const StaleOrderLoadRequested();
}

class StaleOrderRefreshRequested extends StaleOrderEvent {
  const StaleOrderRefreshRequested();
}

class StaleOrderLoadMoreRequested extends StaleOrderEvent {
  const StaleOrderLoadMoreRequested();
}
