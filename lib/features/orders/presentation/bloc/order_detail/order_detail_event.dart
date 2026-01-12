import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/orderdetail/domain/entities/order_detail_entity.dart';
import 'package:gaaubesi_vendor/features/orders/domain/entities/edit_order_request_entity.dart';

abstract class OrderDetailEvent extends Equatable {
  const OrderDetailEvent();

  @override
  List<Object?> get props => [];
}

class OrderDetailRequested extends OrderDetailEvent {
  final int orderId;

  const OrderDetailRequested({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class OrderDetailRefreshRequested extends OrderDetailEvent {
  final int orderId;

  const OrderDetailRefreshRequested({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class OrderDetailCommentAdded extends OrderDetailEvent {
  final CommentsEntity comment;

  const OrderDetailCommentAdded({required this.comment});

  @override
  List<Object?> get props => [comment];
}

class OrderEditRequested extends OrderDetailEvent {
  final int orderId;
  final OrderEditEntity request;

  const OrderEditRequested({
    required this.orderId,
    required this.request,
  });

  @override
  List<Object?> get props => [orderId, request];
}
