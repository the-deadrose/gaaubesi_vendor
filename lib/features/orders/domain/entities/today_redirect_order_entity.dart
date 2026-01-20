import 'package:equatable/equatable.dart';

class TodayRedirectOrderList extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<TodayRedirectOrder> results;

  const TodayRedirectOrderList({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  @override
  List<Object?> get props => [count, next, previous, results];
}

class TodayRedirectOrder extends Equatable {
  final String parentOrderId;
  final int childOrderId;
  final String childOrderStatus;
  final double childCodCharge;
  final String parentDeliveryCharge;
  final double childDeliveryCharge;
  final DateTime createdOn;

  const TodayRedirectOrder({
    required this.parentOrderId,
    required this.childOrderId,
    required this.childOrderStatus,
    required this.childCodCharge,
    required this.parentDeliveryCharge,
    required this.childDeliveryCharge,
    required this.createdOn,
  });

  @override
  List<Object?> get props => [
    parentOrderId,
    childOrderId,
    childOrderStatus,
    childCodCharge,
    parentDeliveryCharge,
    childDeliveryCharge,
    createdOn,
  ];
}
