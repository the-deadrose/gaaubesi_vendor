import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/features/orderdetail/domain/usecase/fetch_order_detail_usecase.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_detail/order_detail_event.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/bloc/order_detail/order_detail_state.dart';

@injectable
class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  final FetchOrderDetailUseCase fetchOrderDetailUseCase;

  OrderDetailBloc({required this.fetchOrderDetailUseCase})
      : super(const OrderDetailInitial()) {
    on<OrderDetailRequested>(_onOrderDetailRequested);
    on<OrderDetailRefreshRequested>(_onOrderDetailRefreshRequested);
  }

  Future<void> _onOrderDetailRequested(
    OrderDetailRequested event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(const OrderDetailLoading());

    final result = await fetchOrderDetailUseCase(event.orderId);

    result.fold(
      (failure) => emit(OrderDetailError(message: failure.message)),
      (order) => emit(OrderDetailLoaded(order: order)),
    );
  }

  Future<void> _onOrderDetailRefreshRequested(
    OrderDetailRefreshRequested event,
    Emitter<OrderDetailState> emit,
  ) async {
    final result = await fetchOrderDetailUseCase(event.orderId);

    result.fold(
      (failure) => emit(OrderDetailError(message: failure.message)),
      (order) => emit(OrderDetailLoaded(order: order)),
    );
  }
}
