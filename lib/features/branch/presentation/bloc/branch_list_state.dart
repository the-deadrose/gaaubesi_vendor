import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/branch_list_entity.dart';

abstract class BranchListState extends Equatable {
  const BranchListState();

  @override
  List<Object?> get props => [];
}

class BranchListInitial extends BranchListState {}

class BranchListLoading extends BranchListState {
  const BranchListLoading();

  @override
  List<Object?> get props => [];
}

class BranchListLoaded extends BranchListState {
  final List<OrderStatusEntity> branchList;
  final bool isRefreshing;

  const BranchListLoaded({
    required this.branchList,
    this.isRefreshing = false,
  });

  BranchListLoaded copyWith({
    List<OrderStatusEntity>? branchList,
    bool? isRefreshing,
  }) {
    return BranchListLoaded(
      branchList: branchList ?? this.branchList,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [branchList, isRefreshing];
}

class BranchListError extends BranchListState {
  final String message;

  const BranchListError({required this.message});

  @override
  List<Object?> get props => [message];
}
