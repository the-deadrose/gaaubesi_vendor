import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/features/orderdetail/domain/entities/order_detail_entity.dart';
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
    on<OrderDetailCommentAdded>(_onOrderDetailCommentAdded);
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

  void _onOrderDetailCommentAdded(
    OrderDetailCommentAdded event,
    Emitter<OrderDetailState> emit,
  ) {
    debugPrint('[BLOC] OrderDetailCommentAdded event received');
    debugPrint('[BLOC] Current state: ${state.runtimeType}');
    // Only add comment if we have a loaded state
    if (state is OrderDetailLoaded) {
      final currentState = state as OrderDetailLoaded;
      final currentOrder = currentState.order;
      
      debugPrint('[BLOC] Current comments count: ${currentOrder.comments?.length ?? 0}');
      
      // Create updated comments list with the new comment at the beginning
      final updatedComments = [
        event.comment,
        ...?currentOrder.comments,
      ];
      
      debugPrint('[BLOC] Updated comments count: ${updatedComments.length}');
      
      // Create new order entity with updated comments
      final updatedOrder = OrderDetailEntity(
        orderId: currentOrder.orderId,
        orderIdWithStatus: currentOrder.orderIdWithStatus,
        trackId: currentOrder.trackId,
        getIsEditable: currentOrder.getIsEditable,
        orderType: currentOrder.orderType,
        vendorName: currentOrder.vendorName,
        vendorReferenceId: currentOrder.vendorReferenceId,
        sourceBranch: currentOrder.sourceBranch,
        sourceBranchCode: currentOrder.sourceBranchCode,
        destinationBranch: currentOrder.destinationBranch,
        destinationBranchCode: currentOrder.destinationBranchCode,
        warehouseBranch: currentOrder.warehouseBranch,
        receiverName: currentOrder.receiverName,
        receiverNumber: currentOrder.receiverNumber,
        altReceiverNumber: currentOrder.altReceiverNumber,
        receiverAddress: currentOrder.receiverAddress,
        weight: currentOrder.weight,
        codCharge: currentOrder.codCharge,
        deliveryCharge: currentOrder.deliveryCharge,
        packageAccess: currentOrder.packageAccess,
        pickupType: currentOrder.pickupType,
        paymentType: currentOrder.paymentType,
        lastDeliveryStatus: currentOrder.lastDeliveryStatus,
        orderDescription: currentOrder.orderDescription,
        deliveryInstruction: currentOrder.deliveryInstruction,
        createdOn: currentOrder.createdOn,
        createdOnFormatted: currentOrder.createdOnFormatted,
        deliveredDate: currentOrder.deliveredDate,
        deliveredDateFormatted: currentOrder.deliveredDateFormatted,
        hold: currentOrder.hold,
        vendorReturn: currentOrder.vendorReturn,
        isExchangeOrder: currentOrder.isExchangeOrder,
        isRefundOrder: currentOrder.isRefundOrder,
        isActive: currentOrder.isActive,
        qrCode: currentOrder.qrCode,
        messages: currentOrder.messages,
        comments: updatedComments,
      );
      
      debugPrint('[BLOC] Emitting new OrderDetailLoaded state with ${updatedComments.length} comments');
      emit(OrderDetailLoaded(order: updatedOrder));
    }
  }
}
