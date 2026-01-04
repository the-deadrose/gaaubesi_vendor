import 'package:gaaubesi_vendor/features/home/domain/entities/vendor_stats_entity.dart';

class VendorStatsModel extends VendorStatsEntity {
  const VendorStatsModel({
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
    required super.totalPackagesValue,
    required super.deliveredPackagesValue,
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
    required super.trueReturnedPackages,
    required super.falseReturnedPackages,
    required super.vendorName,
    required super.processingOrders,
    required super.orderThirtyDays,
    required super.orderValueThirtyDays,
    required super.lastCodAmount,
    required super.lasstCodDate,
  });

  factory VendorStatsModel.fromJson(Map<String, dynamic> json) {
    // Extract the data object from the response
    final data = json['data'] ?? json;

    return VendorStatsModel(
      successPercent: (data['success_percent'] ?? 0.0).toDouble(),
      returnPercent: (data['return_percent'] ?? 0.0).toDouble(),
      staleOrders: data['stale_orders'] ?? 0,
      todaysComment: data['todays_comment'] ?? 0,
      ordersInProcess: data['orders_in_process'] ?? 0,
      ordersInProcessVal: (data['orders_in_process_val'] ?? 0.0).toDouble(),
      ordersInReturnProcess: data['orders_in_return_process'] ?? 0,
      ordersInDeliveryProcess: data['orders_in_delivery_process'] ?? 0,
      totalDelvCharge: (data['total_delv_charge'] ?? 0.0).toDouble(),
      totalPackages: data['total_packages'] ?? 0,
      deliveredPackages: data['delivered_packages'] ?? 0,
      totalPackagesValue: (data['total_packages_value'] ?? 0.0).toDouble(),
      deliveredPackagesValue: (data['delivered_packages_value'] ?? 0.0)
          .toDouble(),
      pendingCod: (data['pending_cod'] ?? 0.0).toDouble(),
      totalRtvOrder: data['total_rtv_order'] ?? 0,
      totalHoldOrder: data['total_hold_order'] ?? 0,
      todayDelivery: data['today_delivery'] ?? 0,
      redirectPercentage: (data['redirect_percentage'] ?? 0.0).toDouble(),
      todaysReturnedDelivery: data['todays_returned_delivery'] ?? 0,
      redirectOrderReturnedPercent:
          (data['redirect_order_returned_percent'] ?? 0.0).toDouble(),
      totalRedirectPercent: (data['total_redirect_percent'] ?? 0.0).toDouble(),
      incomingReturns: data['incoming_returns'] ?? 0,
      todayOrderCreated: data['today_order_created'] ?? 0,
      trueReturnedPackages: ReturnedPackagesModel.fromJson(
        data['true_returned_packages'] ?? {},
      ),
      falseReturnedPackages: ReturnedPackagesModel.fromJson(
        data['false_returned_packages'] ?? {},
      ),
      vendorName: data['vendor_name'] ?? '',
      processingOrders: ProcessingOrdersModel.fromJson(
        data['processing_orders'] ?? {},
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
      lastCodAmount: (data['last_cod_amount'] ?? 0.0).toDouble(),
      lasstCodDate: data['lasst_cod_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success_percent': successPercent,
      'return_percent': returnPercent,
      'stale_orders': staleOrders,
      'todays_comment': todaysComment,
      'orders_in_process': ordersInProcess,
      'orders_in_process_val': ordersInProcessVal,
      'orders_in_return_process': ordersInReturnProcess,
      'orders_in_delivery_process': ordersInDeliveryProcess,
      'total_delv_charge': totalDelvCharge,
      'total_packages': totalPackages,
      'delivered_packages': deliveredPackages,
      'total_packages_value': totalPackagesValue,
      'delivered_packages_value': deliveredPackagesValue,
      'pending_cod': pendingCod,
      'total_rtv_order': totalRtvOrder,
      'total_hold_order': totalHoldOrder,
      'today_delivery': todayDelivery,
      'redirect_percentage': redirectPercentage,
      'todays_returned_delivery': todaysReturnedDelivery,
      'redirect_order_returned_percent': redirectOrderReturnedPercent,
      'total_redirect_percent': totalRedirectPercent,
      'incoming_returns': incomingReturns,
      'today_order_created': todayOrderCreated,
      'true_returned_packages': (trueReturnedPackages as ReturnedPackagesModel)
          .toJson(),
      'false_returned_packages':
          (falseReturnedPackages as ReturnedPackagesModel).toJson(),
      'vendor_name': vendorName,
      'processing_orders': (processingOrders as ProcessingOrdersModel).toJson(),
      'order_thirty_days': orderThirtyDays
          .map((e) => (e as OrderDataModel).toJson())
          .toList(),
      'order_value_thirty_days': orderValueThirtyDays
          .map((e) => (e as OrderValueDataModel).toJson())
          .toList(),
      'last_cod_amount': lastCodAmount,
      'lasst_cod_date': lasstCodDate,
    };
  }
}

class ReturnedPackagesModel extends ReturnedPackagesEntity {
  const ReturnedPackagesModel({required super.count, required super.value});

  factory ReturnedPackagesModel.fromJson(Map<String, dynamic> json) {
    return ReturnedPackagesModel(
      count: json['count'] ?? 0,
      value: (json['value'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'count': count, 'value': value};
  }
}

class ProcessingOrdersModel extends ProcessingOrdersEntity {
  const ProcessingOrdersModel({
    required super.packed,
    required super.shipped,
    required super.qcPending,
  });

  factory ProcessingOrdersModel.fromJson(Map<String, dynamic> json) {
    return ProcessingOrdersModel(
      packed: json['packed'] ?? 0,
      shipped: json['shipped'] ?? 0,
      qcPending: json['qc_pending'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'packed': packed, 'shipped': shipped, 'qc_pending': qcPending};
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
      createdOnDate: json['created_on_date'] ?? '',
      date: json['date'] ?? '',
      orders: json['orders'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'created_on_date': createdOnDate, 'date': date, 'orders': orders};
  }
}

class OrderValueDataModel extends OrderValueDataEntity {
  const OrderValueDataModel({required super.createdOnDate, required super.cod});

  factory OrderValueDataModel.fromJson(Map<String, dynamic> json) {
    return OrderValueDataModel(
      createdOnDate: json['created_on__date'] ?? '',
      cod: (json['cod'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'created_on__date': createdOnDate, 'cod': cod};
  }
}
