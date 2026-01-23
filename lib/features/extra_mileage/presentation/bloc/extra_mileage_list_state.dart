import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/domain/entity/extra_mileage_list_entity.dart';

class ExtraMileageListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExtraMileageListInitialState extends ExtraMileageListState {}

class ExtraMileageListLoadingState extends ExtraMileageListState {}

class ExtraMileageListEmptyState extends ExtraMileageListState {}

class ExtraMileageListLoadedState extends ExtraMileageListState {
  final ExtraMileageResponseListEntity extraMileageList;
  ExtraMileageListLoadedState({required this.extraMileageList});

  @override
  List<Object?> get props => [extraMileageList];
}

class ExtraMileageListErrorState extends ExtraMileageListState {
  final String message;
  ExtraMileageListErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class ExtraMileageListPaginatingState extends ExtraMileageListState {}

class ExtraMileageListPaginatedState extends ExtraMileageListState {
  final ExtraMileageResponseListEntity extraMileageList;
  ExtraMileageListPaginatedState({required this.extraMileageList});

  @override
  List<Object?> get props => [extraMileageList];
}
