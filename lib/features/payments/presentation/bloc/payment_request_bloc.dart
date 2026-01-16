import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/payments/domain/entity/payment_request_list_entity.dart';
import 'package:gaaubesi_vendor/features/payments/domain/usecase/payement_request_list_usecase.dart';
import 'package:gaaubesi_vendor/features/payments/presentation/bloc/payment_request_event.dart';
import 'package:gaaubesi_vendor/features/payments/presentation/bloc/payment_request_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class PaymentRequestBloc
    extends Bloc<PaymentRequestEvent, PaymentRequestState> {
  final PayementRequestListUsecase _getPaymentRequestList;

  PaymentRequestBloc(this._getPaymentRequestList)
    : super(PaymentRequestListInitial()) {
    on<LoadPaymentRequestList>(_onLoadPaymentRequestList);
    on<RefreshPaymentRequestList>(_onRefreshPaymentRequestList);
  }

  Future<void> _onLoadPaymentRequestList(
    LoadPaymentRequestList event,
    Emitter<PaymentRequestState> emit,
  ) async {
    emit(PaymentRequestListLoading());

    final result = await _getPaymentRequestList(NoParams());

    _handlePaymentRequestListResult(result, emit);
  }

  Future<void> _onRefreshPaymentRequestList(
    RefreshPaymentRequestList event,
    Emitter<PaymentRequestState> emit,
  ) async {
    emit(PaymentRequestListLoading());

    final result = await _getPaymentRequestList(NoParams());

    _handlePaymentRequestListResult(result, emit);
  }

  void _handlePaymentRequestListResult(
    Either<Failure, PaymentRequestList> result,
    Emitter<PaymentRequestState> emit,
  ) {
    result.fold(
      (failure) {
        emit(PaymentRequestListError(failure));
      },
      (paymentRequestList) {
        if (paymentRequestList.paymentMethods.isEmpty &&
            paymentRequestList.bankNames.isEmpty &&
            paymentRequestList.frequentlyUsedMethods.isEmpty) {
          emit(PaymentRequestListEmpty());
        } else {
          emit(PaymentRequestListLoaded(paymentRequestList));
        }
      },
    );
  }
}
