import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/branch/domain/usecase/get_branch_list_usecase.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch_list_event.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch_list_state.dart';

@injectable
class BranchListBloc extends Bloc<BranchListEvent, BranchListState> {
  final GetBranchListUsecase getBranchListUsecase;

  BranchListBloc({
    required this.getBranchListUsecase,
  }) : super(BranchListInitial()) {
    on<FetchBranchListEvent>(_onFetchBranchList);
    on<RefreshBranchListEvent>(_onRefreshBranchList);
  }

  Future<void> _onFetchBranchList(
    FetchBranchListEvent event,
    Emitter<BranchListState> emit,
  ) async {
    emit(const BranchListLoading());

    final result = await getBranchListUsecase(NoParams());

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
    // If we have existing data, show it while refreshing
    if (state is BranchListLoaded) {
      final currentState = state as BranchListLoaded;
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(const BranchListLoading());
    }

    final result = await getBranchListUsecase(NoParams());

    result.fold(
      (failure) {
        if (failure.message == 'Session expired') {
          debugPrint('[BranchListBloc] Session expired, not emitting error state');
          return;
        }

        // If we were refreshing, keep the old data but stop the refresh indicator
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
