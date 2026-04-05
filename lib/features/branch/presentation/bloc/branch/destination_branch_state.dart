import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/branch_list_entity.dart';

abstract class DestinationBranchState extends Equatable {
  const DestinationBranchState();

  @override
  List<Object?> get props => [];
}

class DestinationBranchInitial extends DestinationBranchState {
  const DestinationBranchInitial();
}

class DestinationBranchLoading extends DestinationBranchState {
  const DestinationBranchLoading();

  @override
  List<Object?> get props => [];
}

class DestinationBranchLoaded extends DestinationBranchState {
  final List<BranchListEntity> destinationBranch;
  final bool isRefreshing;

  const DestinationBranchLoaded({
    required this.destinationBranch,
    this.isRefreshing = false,
  });

  DestinationBranchLoaded copyWith({
    List<BranchListEntity>? destinationBranch,
    bool? isRefreshing,
  }) {
    return DestinationBranchLoaded(
      destinationBranch: destinationBranch ?? this.destinationBranch,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [destinationBranch, isRefreshing];
}

class DestinationBranchError extends DestinationBranchState {
  final String message;

  const DestinationBranchError({required this.message});

  @override
  List<Object?> get props => [message];
}
