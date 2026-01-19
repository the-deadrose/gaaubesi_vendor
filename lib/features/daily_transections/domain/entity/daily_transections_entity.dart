import 'package:equatable/equatable.dart';

class DailyTransections extends Equatable {
  final String date;
  final List<DailyOrder> deliveredOrders;
  final List<DailyOrder> returnedOrders;
  final String codTransferTotal;
  final int deliveredOrdersCount;
  final int returnedOrdersCount;
  final String totalCodChargeDelivered;
  final String totalDeliveryChargeDelivered;
  final String totalCodChargeReturned;
  final String totalDeliveryChargeReturned;

  const DailyTransections({
    required this.date,
    required this.deliveredOrders,
    required this.returnedOrders,
    required this.codTransferTotal,
    required this.deliveredOrdersCount,
    required this.returnedOrdersCount,
    required this.totalCodChargeDelivered,
    required this.totalDeliveryChargeDelivered,
    required this.totalCodChargeReturned,
    required this.totalDeliveryChargeReturned,
  });

  @override
  List<Object?> get props => [
    date,
    deliveredOrders,
    returnedOrders,
    codTransferTotal,
    deliveredOrdersCount,
    returnedOrdersCount,
    totalCodChargeDelivered,
    totalDeliveryChargeDelivered,
    totalCodChargeReturned,
    totalDeliveryChargeReturned,
  ];
}

class DailyOrder extends Equatable {
  final int orderId;
  final String codCharge;
  final String deliveryCharge;
  final DateTime deliveredDate;
  final String deliveredDateFormatted;

  const DailyOrder({
    required this.orderId,
    required this.codCharge,
    required this.deliveryCharge,
    required this.deliveredDate,
    required this.deliveredDateFormatted,
  });

  @override
  List<Object?> get props => [
    orderId,
    codCharge,
    deliveryCharge,
    deliveredDate,
    deliveredDateFormatted,
  ];
}
