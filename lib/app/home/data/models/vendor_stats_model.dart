import 'package:gaaubesi_vendor/app/home/domain/entities/vendor_stats_entity.dart';

class VendorStatsModel extends VendorStatsEntity {
  const VendorStatsModel({
    required super.vendorName,
    required super.successPercent,
    required super.returnPercent,
    required super.staleOrders,
    required super.todaysComment,
    required super.ordersInProcess,
    required super.ordersInProcessVal,
    required super.ordersInReturnProcess,
    required super.ordersInDeliveryProcess,
    required super.totalDelvCharge,
    required super.totalPackages,
    required super.deliveredPackages,
    required super.trueReturnedPackages,
    required super.totalPackagesValue,
    required super.deliveredPackagesValue,
    required super.falseReturnedPackages,
    required super.pendingCod,
    required super.totalRtvOrder,
    required super.totalHoldOrder,
    required super.todayDelivery,
    required super.redirectPercentage,
    required super.todaysReturnedDelivery,
    required super.redirectOrderReturnedPercent,
    required super.totalRedirectPercent,
    required super.incomingReturns,
    required super.todayOrderCreated,
    required super.processingOrders,
    required super.orderThirtyDays,
    required super.orderValueThirtyDays,
    required super.lastCodAmount,
    required super.lasstCodDate,
  });

  factory VendorStatsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return VendorStatsModel(
      vendorName: (data['vendor_name'] as String?) ?? '',
      successPercent: (data['success_percent'] as num?)?.toDouble() ?? 0.0,
      returnPercent: (data['return_percent'] as num?)?.toDouble() ?? 0.0,
      staleOrders: (data['stale_orders'] as int?) ?? 0,
      todaysComment: (data['todays_comment'] as int?) ?? 0,
      ordersInProcess: (data['orders_in_process'] as int?) ?? 0,
      ordersInProcessVal:
          (data['orders_in_process_val'] as num?)?.toDouble() ?? 0.0,
      ordersInReturnProcess: (data['orders_in_return_process'] as int?) ?? 0,
      ordersInDeliveryProcess:
          (data['orders_in_delivery_process'] as int?) ?? 0,
      totalDelvCharge: (data['total_delv_charge'] as num?)?.toDouble() ?? 0.0,
      totalPackages: (data['total_packages'] as int?) ?? 0,
      deliveredPackages: (data['delivered_packages'] as int?) ?? 0,
      trueReturnedPackages: ReturnedPackagesModel.fromJson(
        (data['true_returned_packages'] as Map<String, dynamic>?) ?? {},
      ),
      totalPackagesValue:
          (data['total_packages_value'] as num?)?.toDouble() ?? 0.0,
      deliveredPackagesValue:
          (data['delivered_packages_value'] as num?)?.toDouble() ?? 0.0,
      falseReturnedPackages: ReturnedPackagesModel.fromJson(
        (data['false_returned_packages'] as Map<String, dynamic>?) ?? {},
      ),
      pendingCod: (data['pending_cod'] as num?)?.toDouble() ?? 0.0,
      totalRtvOrder: (data['total_rtv_order'] as int?) ?? 0,
      totalHoldOrder: (data['total_hold_order'] as int?) ?? 0,
      todayDelivery: (data['today_delivery'] as int?) ?? 0,
      redirectPercentage:
          (data['redirect_percentage'] as num?)?.toDouble() ?? 0.0,
      todaysReturnedDelivery: (data['todays_returned_delivery'] as int?) ?? 0,
      redirectOrderReturnedPercent:
          (data['redirect_order_returned_percent'] as num?)?.toDouble() ?? 0.0,
      totalRedirectPercent:
          (data['total_redirect_percent'] as num?)?.toDouble() ?? 0.0,
      incomingReturns: (data['incoming_returns'] as int?) ?? 0,
      todayOrderCreated: (data['today_order_created'] as int?) ?? 0,
      processingOrders: ProcessingOrdersModel.fromJson(
        (data['processing_orders'] as Map<String, dynamic>?) ?? {},
      ),
      orderThirtyDays:
          (data['order_thirty_days'] as List<dynamic>?)
              ?.map((e) => OrderDataModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      orderValueThirtyDays:
          (data['order_value_thirty_days'] as List<dynamic>?)
              ?.map(
                (e) => OrderValueDataModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      lastCodAmount: (data['last_cod_amount'] as num?)?.toDouble() ?? 0.0,
      lasstCodDate: (data['lasst_cod_date'] as String?) ?? '',
    );
  }
}

class ReturnedPackagesModel extends ReturnedPackagesEntity {
  const ReturnedPackagesModel({required super.count, required super.value});

  factory ReturnedPackagesModel.fromJson(Map<String, dynamic> json) {
    return ReturnedPackagesModel(
      count: (json['count'] as int?) ?? 0,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }


}

class ProcessingOrdersModel extends ProcessingOrdersEntity {
  const ProcessingOrdersModel({
    required super.dropOff,
    required super.pickup,
    required super.sentPickup,
    required super.pickupComplete,
    required super.dispatch,
    required super.rtvDispatch,
    required super.arrived,
    required super.rtvArrived,
    required super.sentForDeliv,
    required super.returnToWarehouse,
    required super.sentToVendor,
    required super.hold,
  });

  factory ProcessingOrdersModel.fromJson(Map<String, dynamic> json) {
    return ProcessingOrdersModel(
      dropOff: (json['drop_off'] as int?) ?? 0,
      pickup: (json['pickup'] as int?) ?? 0,
      sentPickup: (json['sent_pickup'] as int?) ?? 0,
      pickupComplete: (json['pickup_complete'] as int?) ?? 0,
      dispatch: (json['dispatch'] as int?) ?? 0,
      rtvDispatch: (json['rtv_dispatch'] as int?) ?? 0,
      arrived: (json['arrived'] as int?) ?? 0,
      rtvArrived: (json['rtv_arrived'] as int?) ?? 0,
      sentForDeliv: (json['sent_for_deliv'] as int?) ?? 0,
      returnToWarehouse: (json['return_to_warehouse'] as int?) ?? 0,
      sentToVendor: (json['sent_to_vendor'] as int?) ?? 0,
      hold: (json['hold'] as int?) ?? 0,
    );
  }


}

class OrderDataModel extends OrderDataEntity {
  const OrderDataModel({
    required super.createdOnDate,
    required super.date,
    required super.orders,
  });

  factory OrderDataModel.fromJson(Map<String, dynamic> json) {
    return OrderDataModel(
      createdOnDate: (json['created_on__date'] as String?) ?? '',
      date: (json['date'] as String?) ?? '',
      orders: (json['orders'] as int?) ?? 0,
    );
  }


}

class OrderValueDataModel extends OrderValueDataEntity {
  const OrderValueDataModel({required super.createdOnDate, required super.cod});

  factory OrderValueDataModel.fromJson(Map<String, dynamic> json) {
    return OrderValueDataModel(
      createdOnDate: (json['created_on__date'] as String?) ?? '',
      cod: (json['cod'] as num?)?.toDouble() ?? 0.0,
    );
  }


}
