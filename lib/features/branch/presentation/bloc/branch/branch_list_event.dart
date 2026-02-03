import 'package:equatable/equatable.dart';

abstract class BranchListEvent extends Equatable {
  const BranchListEvent();

  @override
  List<Object?> get props => [];
}

class FetchBranchListEvent extends BranchListEvent {
  final String branch;

  const FetchBranchListEvent(this.branch);

  @override
  List<Object?> get props => [branch];
}

class RefreshBranchListEvent extends BranchListEvent {
  final String branch;

  const RefreshBranchListEvent(this.branch);

  @override
  List<Object?> get props => [branch];
}


class FetchPickupPointsEvent extends BranchListEvent {
  const FetchPickupPointsEvent();

  @override
  List<Object?> get props => [];
}

class RefreshPickupPointsEvent extends BranchListEvent {
  const RefreshPickupPointsEvent();

  @override
  List<Object?> get props => [];
}