import 'package:equatable/equatable.dart';

abstract class PossibleRedirectOrderEvent extends Equatable {
  const PossibleRedirectOrderEvent();

  @override
  List<Object?> get props => [];
}

class PossibleRedirectOrderLoadRequested extends PossibleRedirectOrderEvent {
  const PossibleRedirectOrderLoadRequested();
}

class PossibleRedirectOrderRefreshRequested extends PossibleRedirectOrderEvent {
  const PossibleRedirectOrderRefreshRequested();
}

class PossibleRedirectOrderLoadMoreRequested
    extends PossibleRedirectOrderEvent {
  const PossibleRedirectOrderLoadMoreRequested();
}

class PossibleRedirectOrderFilterChanged extends PossibleRedirectOrderEvent {
  final String? destination;
  final String? startDate;
  final String? endDate;
  final String? receiverSearch;

  const PossibleRedirectOrderFilterChanged({
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
