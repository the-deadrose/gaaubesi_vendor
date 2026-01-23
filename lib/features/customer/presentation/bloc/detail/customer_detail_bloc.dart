import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/customer/domain/usecase/customer_detail_usecase.dart';
import 'package:gaaubesi_vendor/features/customer/presentation/bloc/detail/customer_detail_event.dart';
import 'package:gaaubesi_vendor/features/customer/presentation/bloc/detail/customer_detail_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class CustomerDetailBloc extends Bloc<CustomerDetailEvent, CustomerDetailState> {
  final CustomerDetailUsecase _customerDetailUsecase;

  CustomerDetailBloc(this._customerDetailUsecase)
    : super(CustomerDetailInitial()) {
    on<FetchCustomerDetail>(_onFetchCustomerDetail);
    on<ResetCustomerDetailState>(_onResetCustomerDetailState);
  }

  Future<void> _onFetchCustomerDetail(
    FetchCustomerDetail event,
    Emitter<CustomerDetailState> emit,
  ) async {
    try {
      emit(CustomerDetailLoading());

      final result = await _customerDetailUsecase.call(
        CustomerDetailParams(customerId: event.customerId),
      );

      result.fold(
        (failure) {
          emit(CustomerDetailError(failure.toString()));
        },
        (customerDetail) {
          emit(CustomerDetailLoaded(customerDetail: customerDetail));
        },
      );
    } catch (e) {
      emit(
        CustomerDetailError(
          'Failed to fetch customer details: ${e.toString()}',
        ),
      );
    }
  }

  void _onResetCustomerDetailState(
    ResetCustomerDetailState event,
    Emitter<CustomerDetailState> emit,
  ) {
    emit(CustomerDetailInitial());
  }
}