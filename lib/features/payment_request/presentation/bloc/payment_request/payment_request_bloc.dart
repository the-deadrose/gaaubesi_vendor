import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/entity/payment_request_list_entity.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/usecase/create_payment_request_usecase.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/usecase/fetch_payment_request_usecase.dart';
import 'package:gaaubesi_vendor/features/payment_request/presentation/bloc/payment_request/payment_request_event.dart';
import 'package:gaaubesi_vendor/features/payment_request/presentation/bloc/payment_request/payment_request_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class PaymentRequestBloc extends Bloc<PaymentRequestEvent, PaymentRequestState> {
  final CreatePaymentRequestUsecase _createPaymentRequestUsecase;
  final FetchPaymentRequestUsecase _fetchPaymentRequestUsecase;

  PaymentRequestBloc(
    this._createPaymentRequestUsecase,
    this._fetchPaymentRequestUsecase,
  ) : super(FetchPaymentRequestsInitial()) {
    on<CreatePaymentRequestEvent>(_onCreatePaymentRequest);
    on<FetchPaymentRequestsEvent>(_onFetchPaymentRequests);
  }

  Future<void> _onCreatePaymentRequest(
    CreatePaymentRequestEvent event,
    Emitter<PaymentRequestState> emit,
  ) async {
    emit(CreatePaymentRequestLoading());

    final params = CreatePaymentRequestParams(
      paymentMethod: event.paymentMethod,
      description: event.description,
      bankName: event.bankName,
      accountNumber: event.accountNumber,
      accountName: event.accountName,
      phoneNumber: event.phoneNumber,
    );

    final result = await _createPaymentRequestUsecase.call(params);

    result.fold(
      (failure) {
        emit(CreatePaymentRequestFailure(error: failure.message));
      },
      (_) {
        emit(CreatePaymentRequestSuccess(
          message: 'Payment request created successfully',
        ));
      },
    );
  }

  Future<void> _onFetchPaymentRequests(
    FetchPaymentRequestsEvent event,
    Emitter<PaymentRequestState> emit,
  ) async {
    // Only show loading state if not paginating (first page)
    if (event.page == '1' || state is! FetchPaymentRequestsSuccess) {
      emit(FetchPaymentRequestsLoading());
    }

    final params = FetchPaymentRequestUsecaseParams(
      page: event.page,
      status: event.status,
      paymentMethod: event.paymentMethod,
      bankName: event.bankName,
    );

    final result = await _fetchPaymentRequestUsecase.call(params);

    result.fold(
      (failure) {
        emit(FetchPaymentRequestsFailure(error: failure.message));
      },
      (paymentRequestList) {
        if (paymentRequestList.results.isEmpty && event.page == '1') {
          emit(PaymentRequestListEmpty());
        } else if (event.page != '1' && state is FetchPaymentRequestsSuccess) {
          // Append new results to existing ones during pagination
          final currentState = state as FetchPaymentRequestsSuccess;
          final combinedResults = [
            ...currentState.paymentRequestList.results,
            ...paymentRequestList.results,
          ];
          emit(FetchPaymentRequestsSuccess(
            paymentRequestList: PaymentRequestListEntity(
              count: paymentRequestList.count,
              next: paymentRequestList.next,
              previous: paymentRequestList.previous,
              results: combinedResults,
              paymentMethods: paymentRequestList.paymentMethods,
              bankNames: paymentRequestList.bankNames,
            ),
          ));
        } else {
          emit(FetchPaymentRequestsSuccess(
            paymentRequestList: paymentRequestList,
          ));
        }
      },
    );
  }
}