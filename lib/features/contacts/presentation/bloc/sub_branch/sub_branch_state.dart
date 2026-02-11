import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/sub_branch_entity.dart';

class SubBranchState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubBranchInitialState extends SubBranchState {}

class SubBranchLoadingState extends SubBranchState {}

class SubBranchLoadedState extends SubBranchState {
  final SubBranchesResponseEntity subBranchesResponseEntity;

  SubBranchLoadedState({required this.subBranchesResponseEntity});

  @override
  List<Object?> get props => [subBranchesResponseEntity];
}

class SubBranchErrorState extends SubBranchState {
  final String message;

  SubBranchErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class SubBranchEmptyState extends SubBranchState {}

class SubBranchPaginating extends SubBranchState {}

class SubBranchPaginatingError extends SubBranchState {
  final String message;

  SubBranchPaginatingError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SubBranchPaginated extends SubBranchState {
  final SubBranchesResponseEntity subBranchesResponseEntity;

  SubBranchPaginated({required this.subBranchesResponseEntity});

  @override
  List<Object?> get props => [subBranchesResponseEntity];
}
