import 'package:equatable/equatable.dart';

class DeliveryReportAnalysisEntity extends Equatable {
  final String fromDate;
  final String toDate;
  final int totalDeliveredOrders;
  final String totalDeliveredValue;
  final String totalDeliveredCharge;
  final int totalReturnedOrders;
  final String totalReturnedValue;
  final String totalReturnedCharge;
  final List<DailyReportEntity> dailyReports;

  const DeliveryReportAnalysisEntity({
    required this.fromDate,
    required this.toDate,
    required this.totalDeliveredOrders,
    required this.totalDeliveredValue,
    required this.totalDeliveredCharge,
    required this.totalReturnedOrders,
    required this.totalReturnedValue,
    required this.totalReturnedCharge,
    required this.dailyReports,
  });

  @override
  List<Object?> get props => [
    fromDate,
    toDate,
    totalDeliveredOrders,
    totalDeliveredValue,
    totalDeliveredCharge,
    totalReturnedOrders,
    totalReturnedValue,
    totalReturnedCharge,
    dailyReports,
  ];
}

class DailyReportEntity extends Equatable {
  final String deliveredDate;
  final int deliveredOrders;
  final String deliveredOrdersPackageValue;
  final String deliveredOrdersDeliveryCharge;
  final int returnedOrders;
  final String returnedOrdersPackageValue;
  final String returnedOrdersDeliveryCharge;

  const DailyReportEntity({
    required this.deliveredDate,
    required this.deliveredOrders,
    required this.deliveredOrdersPackageValue,
    required this.deliveredOrdersDeliveryCharge,
    required this.returnedOrders,
    required this.returnedOrdersPackageValue,
    required this.returnedOrdersDeliveryCharge,
  });

  @override
  List<Object?> get props => [
    deliveredDate,
    deliveredOrders,
    deliveredOrdersPackageValue,
    deliveredOrdersDeliveryCharge,
    returnedOrders,
    returnedOrdersPackageValue,
    returnedOrdersDeliveryCharge,
  ];
}
