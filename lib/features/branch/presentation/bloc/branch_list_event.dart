import 'package:equatable/equatable.dart';

abstract class BranchListEvent extends Equatable {
  const BranchListEvent();

  @override
  List<Object?> get props => [];
}

class FetchBranchListEvent extends BranchListEvent {
  const FetchBranchListEvent();

  @override
  List<Object?> get props => [];
}

class RefreshBranchListEvent extends BranchListEvent {
  const RefreshBranchListEvent();

  @override
  List<Object?> get props => [];
}
