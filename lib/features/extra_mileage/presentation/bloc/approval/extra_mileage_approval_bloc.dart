import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/domain/usecase/approve_extra_mileage_usecase.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/domain/usecase/decline_extra_mileage_usecase.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/presentation/bloc/approval/extra_mileage_approval_event.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/presentation/bloc/approval/extra_mileage_approval_state.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ExtraMileageApprovalBloc
    extends Bloc<ExtraMileageApprovalEvent, ExtraMileageApprovalState> {
  final ApproveExtraMileageUsecase _approveExtraMileageUsecase;
  final DeclineExtraMileageUsecase _declineExtraMileageUsecase;

  ExtraMileageApprovalBloc(
    this._approveExtraMileageUsecase,
    this._declineExtraMileageUsecase,
  ) : super(ExtraMileageApprovalInitialState()) {
    on<ApproveExtraMileageRequestEvent>(_onApproveExtraMileage);
    on<DeclineExtraMileageRequestEvent>(_onDeclineExtraMileage);
  }

  Future<void> _onApproveExtraMileage(
    ApproveExtraMileageRequestEvent event,
    Emitter<ExtraMileageApprovalState> emit,
  ) async {
    emit(ExtraMileageApprovalLoadingState());

    final result = await _approveExtraMileageUsecase.call(
      ApproveExtraMileageUsecaseParams(mileageId: event.mileageId),
    );

    result.fold(
      (failure) => emit(
        ExtraMileageApprovalErrorState(
          message: _mapFailureToMessage(failure),
        ),
      ),
      (_) => emit(ExtraMileageApprovedSuccessState()),
    );
  }

  Future<void> _onDeclineExtraMileage(
    DeclineExtraMileageRequestEvent event,
    Emitter<ExtraMileageApprovalState> emit,
  ) async {
    emit(ExtraMileageApprovalLoadingState());

    final result = await _declineExtraMileageUsecase.call(
      DeclineExtraMileageUsecaseParams(mileageId: event.mileageId),
    );

    result.fold(
      (failure) => emit(
        ExtraMileageApprovalErrorState(
          message: _mapFailureToMessage(failure),
        ),
      ),
      (_) => emit(ExtraMileageDeclinedSuccessState()),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Network error. Please check your connection.';
    } else if (failure is CacheFailure) {
      return failure.message;
    } else if (failure is ValidationFailure) {
      return failure.message;
    }
    return 'An unexpected error occurred';
  }
}
