import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/branch/domain/usecase/get_destination_branch_list_usecase.dart'
    as destination_branch;
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_event.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/destination_branch_state.dart';

@injectable
class DestinationBranchBloc
    extends Bloc<BranchListEvent, DestinationBranchState> {
  final destination_branch.GetDestinationBranchListUsecase
      getDestinationBranchListUsecase;

  DestinationBranchBloc({
    required this.getDestinationBranchListUsecase,
  }) : super(const DestinationBranchInitial()) {
    on<FetchDestinationBranchEvent>(_onFetchDestinationBranch);
    on<RefreshDestinationBranchEvent>(_onRefreshDestinationBranch);
  }

  Future<void> _onFetchDestinationBranch(
    FetchDestinationBranchEvent event,
    Emitter<DestinationBranchState> emit,
  ) async {
    emit(const DestinationBranchLoading());

    final result = await getDestinationBranchListUsecase(
      destination_branch.BranchParams(event.branch),
    );

    result.fold(
      (failure) {
        if (failure.message == 'Session expired') {
          debugPrint('[DestinationBranchBloc] Session expired, not emitting error state');
          return;
        }

        emit(DestinationBranchError(
          message: _mapFailureToMessage(failure),
        ));
      },
      (destinationBranch) {
        debugPrint('[DestinationBranchBloc] Emitting DestinationBranchLoaded with ${destinationBranch.length} branch(es)');
        if (destinationBranch.isNotEmpty) {
          for (var i = 0; i < destinationBranch.length && i < 3; i++) {
            debugPrint('[DestinationBranchBloc] Destination Branch $i: value=${destinationBranch[i].value}, label=${destinationBranch[i].label}, code=${destinationBranch[i].code}');
          }
        }
        emit(DestinationBranchLoaded(
          destinationBranch: destinationBranch,
        ));
      },
    );
  }

  Future<void> _onRefreshDestinationBranch(
    RefreshDestinationBranchEvent event,
    Emitter<DestinationBranchState> emit,
  ) async {
    if (state is DestinationBranchLoaded) {
      final currentState = state as DestinationBranchLoaded;
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(const DestinationBranchLoading());
    }

    final result = await getDestinationBranchListUsecase(
      destination_branch.BranchParams(event.branch),
    );

    result.fold(
      (failure) {
        if (failure.message == 'Session expired') {
          debugPrint('[DestinationBranchBloc] Session expired, not emitting error state');
          return;
        }

        if (state is DestinationBranchLoaded) {
          final currentState = state as DestinationBranchLoaded;
          emit(currentState.copyWith(isRefreshing: false));
        } else {
          emit(DestinationBranchError(
            message: _mapFailureToMessage(failure),
          ));
        }
      },
      (destinationBranch) {
        emit(DestinationBranchLoaded(
          destinationBranch: destinationBranch,
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
