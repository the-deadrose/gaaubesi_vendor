import 'package:equatable/equatable.dart';

class VendorStatsEntity extends Equatable {
  final String vendorName;
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
  final ProcessingOrdersEntity processingOrders;
  final List<OrderDataEntity> orderThirtyDays;
  final List<OrderValueDataEntity> orderValueThirtyDays;
  final double lastCodAmount;
  final String lasstCodDate;

  const VendorStatsEntity({
    required this.vendorName,
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
    required this.processingOrders,
    required this.orderThirtyDays,
    required this.orderValueThirtyDays,
    required this.lastCodAmount,
    required this.lasstCodDate,
  });

  @override
  List<Object?> get props => [
        vendorName,
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
  final int dropOff;
  final int pickup;
  final int sentPickup;
  final int pickupComplete;
  final int dispatch;
  final int rtvDispatch;
  final int arrived;
  final int rtvArrived;
  final int sentForDeliv;
  final int returnToWarehouse;
  final int sentToVendor;
  final int hold;

  const ProcessingOrdersEntity({
    required this.dropOff,
    required this.pickup,
    required this.sentPickup,
    required this.pickupComplete,
    required this.dispatch,
    required this.rtvDispatch,
    required this.arrived,
    required this.rtvArrived,
    required this.sentForDeliv,
    required this.returnToWarehouse,
    required this.sentToVendor,
    required this.hold,
  });

  @override
  List<Object?> get props => [
        dropOff,
        pickup,
        sentPickup,
        pickupComplete,
        dispatch,
        rtvDispatch,
        arrived,
        rtvArrived,
        sentForDeliv,
        returnToWarehouse,
        sentToVendor,
        hold,
      ];
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