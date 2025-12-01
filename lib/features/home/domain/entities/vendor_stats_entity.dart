import 'package:equatable/equatable.dart';

class VendorStatsEntity extends Equatable {
  final double successPercent;
  final double returnPercent;
  final int staleOrders;
  final int todaysComment;
  final int ordersInProcess;
  final double ordersInProcessVal;
  final int ordersInReturnProcess;
  final int ordersInDeliveryProcess;
  final double totalDelvCharge;
  final int totalPackages;
  final int deliveredPackages;
  final double totalPackagesValue;
  final double deliveredPackagesValue;
  final double pendingCod;
  final int totalRtvOrder;
  final int totalHoldOrder;
  final int todayDelivery;
  final double redirectPercentage;
  final int todaysReturnedDelivery;
  final double redirectOrderReturnedPercent;
  final double totalRedirectPercent;
  final int incomingReturns;
  final int todayOrderCreated;
  final ReturnedPackagesEntity trueReturnedPackages;
  final ReturnedPackagesEntity falseReturnedPackages;
  final String vendorName;
  final ProcessingOrdersEntity processingOrders;
  final List<OrderDataEntity> orderThirtyDays;
  final List<OrderValueDataEntity> orderValueThirtyDays;
  final double lastCodAmount;
  final String lasstCodDate;

  const VendorStatsEntity({
    required this.successPercent,
    required this.returnPercent,
    required this.staleOrders,
    required this.todaysComment,
    required this.ordersInProcess,
    required this.ordersInProcessVal,
    required this.ordersInReturnProcess,
    required this.ordersInDeliveryProcess,
    required this.totalDelvCharge,
    required this.totalPackages,
    required this.deliveredPackages,
    required this.totalPackagesValue,
    required this.deliveredPackagesValue,
    required this.pendingCod,
    required this.totalRtvOrder,
    required this.totalHoldOrder,
    required this.todayDelivery,
    required this.redirectPercentage,
    required this.todaysReturnedDelivery,
    required this.redirectOrderReturnedPercent,
    required this.totalRedirectPercent,
    required this.incomingReturns,
    required this.todayOrderCreated,
    required this.trueReturnedPackages,
    required this.falseReturnedPackages,
    required this.vendorName,
    required this.processingOrders,
    required this.orderThirtyDays,
    required this.orderValueThirtyDays,
    required this.lastCodAmount,
    required this.lasstCodDate,
  });

  @override
  List<Object?> get props => [
    successPercent,
    returnPercent,
    staleOrders,
    todaysComment,
    ordersInProcess,
    ordersInProcessVal,
    ordersInReturnProcess,
    ordersInDeliveryProcess,
    totalDelvCharge,
    totalPackages,
    deliveredPackages,
    totalPackagesValue,
    deliveredPackagesValue,
    pendingCod,
    totalRtvOrder,
    totalHoldOrder,
    todayDelivery,
    redirectPercentage,
    todaysReturnedDelivery,
    redirectOrderReturnedPercent,
    totalRedirectPercent,
    incomingReturns,
    todayOrderCreated,
    trueReturnedPackages,
    falseReturnedPackages,
    vendorName,
    processingOrders,
    orderThirtyDays,
    orderValueThirtyDays,
    lastCodAmount,
    lasstCodDate,
  ];
}

class ReturnedPackagesEntity extends Equatable {
  final int count;
  final double value;

  const ReturnedPackagesEntity({required this.count, required this.value});

  @override
  List<Object?> get props => [count, value];
}

class ProcessingOrdersEntity extends Equatable {
  final int packed;
  final int shipped;
  final int qcPending;

  const ProcessingOrdersEntity({
    required this.packed,
    required this.shipped,
    required this.qcPending,
  });

  @override
  List<Object?> get props => [packed, shipped, qcPending];
}

class OrderDataEntity extends Equatable {
  final String createdOnDate;
  final String date;
  final int orders;

  const OrderDataEntity({
    required this.createdOnDate,
    required this.date,
    required this.orders,
  });

  @override
  List<Object?> get props => [createdOnDate, date, orders];
}

class OrderValueDataEntity extends Equatable {
  final String createdOnDate;
  final double cod;

  const OrderValueDataEntity({required this.createdOnDate, required this.cod});

  @override
  List<Object?> get props => [createdOnDate, cod];
}
