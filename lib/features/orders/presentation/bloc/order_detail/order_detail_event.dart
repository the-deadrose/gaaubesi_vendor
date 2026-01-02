import 'package:equatable/equatable.dart';

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
