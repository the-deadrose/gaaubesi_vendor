import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/calculate_charge/domain/entity/calculate_deliver_charge_entity.dart';
import 'package:gaaubesi_vendor/features/calculate_charge/domain/usecase/calculate_delivery_charge_usecase.dart';
import 'package:gaaubesi_vendor/features/calculate_charge/presentation/bloc/calculate_delivery_charge_event.dart';
import 'package:gaaubesi_vendor/features/calculate_charge/presentation/bloc/calculate_delivery_charge_state.dart';
import 'package:injectable/injectable.dart';


@injectable

class CalculateDeliveryChargeBloc
    extends Bloc<CalculateDeliveryChargeEvent, CalculateDeliveryChargeState> {
  final CalculateDeliveryChargeUsecase _calculateDeliveryChargeUsecase;

  CalculateDeliveryChargeBloc(this._calculateDeliveryChargeUsecase)
      : super(CalculateDeliveryChargeInitial()) {
    on<CalculateDeliveryChargeRequested>((event, emit) async {
      emit(CalculateDeliveryChargeLoading());

      final params = CalculateDeliveryChargeUsecaseParams(
        sourceBranchId: event.sourceBranchId,
        destinationBranchId: event.destinationBranchId,
        weight: event.weight,
      );

      final Either<Failure, CalculateDeliveryCharge> result =
          await _calculateDeliveryChargeUsecase(params);

      result.fold(
        (failure) => emit(
          CalculateDeliveryChargeError(message: _mapFailureToMessage(failure)),
        ),
        (calculateDeliveryCharge) => emit(
          CalculateDeliveryChargeLoaded(
              calculateDeliveryCharge: calculateDeliveryCharge),
        ),
      );
    });
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.message;
  }
}
