import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/usecase/fetch_frequently_used_payment_usecase.dart';
import 'package:gaaubesi_vendor/features/payment_request/presentation/bloc/frequently_used_methods/frequently_used_payment_method_event.dart';
import 'package:gaaubesi_vendor/features/payment_request/presentation/bloc/frequently_used_methods/frequently_used_payment_method_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class FrequentlyUsedPaymentMethodBloc
    extends
        Bloc<
          FrequentlyUsedPaymentMethodEvent,
          FrequentlyUsedPaymentMethodState
        > {
  final FetchFrequentlyUsedPaymentUsecase _fetchFrequentlyUsedPaymentUsecase;

  FrequentlyUsedPaymentMethodBloc(this._fetchFrequentlyUsedPaymentUsecase)
    : super(FrequentlyUsedPaymentMethodInitial()) {
    on<FetchFrequentlyUsedPaymentMethodEvent>(
      _onFetchFrequentlyUsedPaymentMethod,
    );
  }

  Future<void> _onFetchFrequentlyUsedPaymentMethod(
    FetchFrequentlyUsedPaymentMethodEvent event,
    Emitter<FrequentlyUsedPaymentMethodState> emit,
  ) async {
    emit(FrequentlyUsedPaymentMethodLoading());

    final result = await _fetchFrequentlyUsedPaymentUsecase.call(NoParams());

    result.fold(
      (failure) {
        emit(FrequentlyUsedPaymentMethodError(failure.message));
      },
      (frequentlyUsedAndPaymentMethodList) {
        if (frequentlyUsedAndPaymentMethodList.paymentMethods.isEmpty &&
            frequentlyUsedAndPaymentMethodList.frequentlyUsedMethods.isEmpty) {
          emit(FrequentlyUsedPaymentMethodEmpty());
        } else {
          emit(
            FrequentlyUsedPaymentMethodLoaded(
              frequentlyUsedAndPaymentMethodList,
            ),
          );
        }
      },
    );
  }
}
