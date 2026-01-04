import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeLoadStats extends HomeEvent {
  const HomeLoadStats();
}

class HomeRefreshStats extends HomeEvent {
  const HomeRefreshStats();
}

class HomeToggleAmountVisibility extends HomeEvent {
  const HomeToggleAmountVisibility();
}