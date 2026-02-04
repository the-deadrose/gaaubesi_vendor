import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/branch/domain/usecase/get_pickup_point_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/branch/domain/usecase/get_branch_list_usecase.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_event.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_state.dart';

@injectable
class BranchListBloc extends Bloc<BranchListEvent, BranchListState> {
  final GetBranchListUsecase getBranchListUsecase;
  final GetPickupPointUsecase getPickupPointUsecase;

  BranchListBloc({
    required this.getBranchListUsecase,
    required this.getPickupPointUsecase,
  }) : super(BranchListInitial()) {
    on<FetchBranchListEvent>(_onFetchBranchList);
    on<RefreshBranchListEvent>(_onRefreshBranchList);
    on<FetchPickupPointsEvent>(_onFetchPickupPoints);
    on<RefreshPickupPointsEvent>(_onRefreshPickupPoints);
  }

  Future<void> _onFetchBranchList(
    FetchBranchListEvent event,
    Emitter<BranchListState> emit,
  ) async {
    emit(const BranchListLoading());

    final result = await getBranchListUsecase(BranchParams(event.branch));

    result.fold(
      (failure) {
        if (failure.message == 'Session expired') {
          debugPrint('[BranchListBloc] Session expired, not emitting error state');
          return;
        }
        
        emit(BranchListError(
          message: _mapFailureToMessage(failure),
        ));
      },
      (branchList) {
        debugPrint('[BranchListBloc] Emitting BranchListLoaded with ${branchList.length} branches');
        for (var i = 0; i < branchList.length && i < 3; i++) {
          debugPrint('[BranchListBloc] Branch $i: value=${branchList[i].value}, label=${branchList[i].label}, code=${branchList[i].code}');
        }
        emit(BranchListLoaded(
          branchList: branchList,
        ));
      },
    );
  }

  Future<void> _onRefreshBranchList(
    RefreshBranchListEvent event,
    Emitter<BranchListState> emit,
  ) async {
    if (state is BranchListLoaded) {
      final currentState = state as BranchListLoaded;
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(const BranchListLoading());
    }

    final result = await getBranchListUsecase(BranchParams(
      event.branch,
    ));

    result.fold(
      (failure) {
        if (failure.message == 'Session expired') {
          debugPrint('[BranchListBloc] Session expired, not emitting error state');
          return;
        }

        if (state is BranchListLoaded) {
          final currentState = state as BranchListLoaded;
          emit(currentState.copyWith(isRefreshing: false));
        } else {
          emit(BranchListError(
            message: _mapFailureToMessage(failure),
          ));
        }
      },
      (branchList) {
        emit(BranchListLoaded(
          branchList: branchList,
          isRefreshing: false,
        ));
      },
    );
  }

  Future<void> _onFetchPickupPoints(
    FetchPickupPointsEvent event,
    Emitter<BranchListState> emit,
  ) async {
    emit( PickUpPointLoading());

    final result = await getPickupPointUsecase(NoParams());

    result.fold(
      (failure) {
        if (failure.message == 'Session expired') {
          debugPrint('[BranchListBloc] Session expired, not emitting error state');
          return;
        }

        emit(BranchListError(
          message: _mapFailureToMessage(failure),
        ));
      },
      (pickupPoints) {
        emit(PickUpPointLoaded(
          pickupPoints: pickupPoints,
        ));
      },
    );
  }

  Future<void> _onRefreshPickupPoints(
    RefreshPickupPointsEvent event,
    Emitter<BranchListState> emit,
  ) async {
    emit( PickUpPointLoading());

    final result = await getPickupPointUsecase(NoParams());

    result.fold(
      (failure) {
        if (failure.message == 'Session expired') {
          debugPrint('[BranchListBloc] Session expired, not emitting error state');
          return;
        }

        emit(BranchListError(
          message: _mapFailureToMessage(failure),
        ));
      },
      (pickupPoints) {
        emit(PickUpPointLoaded(
          pickupPoints: pickupPoints,
        ));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Network error. Please check your connection.';
    } else if (failure is CacheFailure) {
      return 'Cache error. Please try again.';
    } else {
      return 'An unexpected error occurred.';
    }
  }
}
