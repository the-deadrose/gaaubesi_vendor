import 'package:gaaubesi_vendor/features/home/domain/entities/vendor_stats_entity.dart';

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
    required super.processingOrders,
    required super.orderThirtyDays,
    required super.orderValueThirtyDays,
    required super.lastCodAmount,
    required super.lasstCodDate,
  });

  factory VendorStatsModel.fromJson(Map<String, dynamic> json) {
    // Extract the data object from the response
    final Map<String, dynamic> data;
    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      data = json['data'] as Map<String, dynamic>;
    } else {
      data = json;
    }

    return VendorStatsModel(
      vendorName: data['vendor_name']?.toString() ?? '',
      successPercent: _parseDouble(data['success_percent']),
      returnPercent: _parseDouble(data['return_percent']),
      staleOrders: _parseInt(data['stale_orders']),
      todaysComment: _parseInt(data['todays_comment']),
      ordersInProcess: _parseInt(data['orders_in_process']),
      ordersInProcessVal: _parseDouble(data['orders_in_process_val']),
      ordersInReturnProcess: _parseInt(data['orders_in_return_process']),
      ordersInDeliveryProcess: _parseInt(data['orders_in_delivery_process']),
      totalDelvCharge: _parseDouble(data['total_delv_charge']),
      totalPackages: _parseInt(data['total_packages']),
      deliveredPackages: _parseInt(data['delivered_packages']),
      totalPackagesValue: _parseDouble(data['total_packages_value']),
      deliveredPackagesValue: _parseDouble(data['delivered_packages_value']),
      pendingCod: _parseDouble(data['pending_cod']),
      totalRtvOrder: _parseInt(data['total_rtv_order']),
      totalHoldOrder: _parseInt(data['total_hold_order']),
      todayDelivery: _parseInt(data['today_delivery']),
      redirectPercentage: _parseDouble(data['redirect_percentage']),
      todaysReturnedDelivery: _parseInt(data['todays_returned_delivery']),
      redirectOrderReturnedPercent: 
          _parseDouble(data['redirect_order_returned_percent']),
      totalRedirectPercent: _parseDouble(data['total_redirect_percent']),
      incomingReturns: _parseInt(data['incoming_returns']),
      todayOrderCreated: _parseInt(data['today_order_created']),
      trueReturnedPackages: ReturnedPackagesModel.fromJson(
        data['true_returned_packages'] is Map<String, dynamic> 
            ? data['true_returned_packages'] as Map<String, dynamic>
            : <String, dynamic>{'count': 0, 'value': 0.0},
      ),
      falseReturnedPackages: ReturnedPackagesModel.fromJson(
        data['false_returned_packages'] is Map<String, dynamic>
            ? data['false_returned_packages'] as Map<String, dynamic>
            : <String, dynamic>{'count': 0, 'value': 0.0},
      ),
      processingOrders: ProcessingOrdersModel.fromJson(
        data['processing_orders'] is Map<String, dynamic>
            ? data['processing_orders'] as Map<String, dynamic>
            : <String, dynamic>{},
      ),
      orderThirtyDays: _parseOrderList(data['order_thirty_days']),
      orderValueThirtyDays: _parseOrderValueList(data['order_value_thirty_days']),
      lastCodAmount: _parseDouble(data['last_cod_amount']),
      lasstCodDate: data['lasst_cod_date']?.toString() ?? '',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }

  static List<OrderDataModel> _parseOrderList(dynamic value) {
    if (value == null) return const [];
    if (value is! List) return const [];
    
    final List<dynamic> list = value;
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => OrderDataModel.fromJson(e))
        .toList();
  }

  static List<OrderValueDataModel> _parseOrderValueList(dynamic value) {
    if (value == null) return const [];
    if (value is! List) return const [];
    
    final List<dynamic> list = value;
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => OrderValueDataModel.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'vendor_name': vendorName,
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
      'true_returned_packages': trueReturnedPackages is ReturnedPackagesModel
          ? (trueReturnedPackages as ReturnedPackagesModel).toJson()
          : <String, dynamic>{'count': 0, 'value': 0.0},
      'false_returned_packages': falseReturnedPackages is ReturnedPackagesModel
          ? (falseReturnedPackages as ReturnedPackagesModel).toJson()
          : <String, dynamic>{'count': 0, 'value': 0.0},
      'processing_orders': processingOrders is ProcessingOrdersModel
          ? (processingOrders as ProcessingOrdersModel).toJson()
          : <String, dynamic>{},
      'order_thirty_days': orderThirtyDays
          .whereType<OrderDataModel>()
          .map((e) => e.toJson())
          .toList(),
      'order_value_thirty_days': orderValueThirtyDays
          .whereType<OrderValueDataModel>()
          .map((e) => e.toJson())
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
      count: _parseInt(json['count']),
      value: _parseDouble(json['value']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {'count': count, 'value': value};
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
      dropOff: _parseInt(json['drop_off']),
      pickup: _parseInt(json['pickup']),
      sentPickup: _parseInt(json['sent_pickup']),
      pickupComplete: _parseInt(json['pickup_complete']),
      dispatch: _parseInt(json['dispatch']),
      rtvDispatch: _parseInt(json['rtv_dispatch']),
      arrived: _parseInt(json['arrived']),
      rtvArrived: _parseInt(json['rtv_arrived']),
      sentForDeliv: _parseInt(json['sent_for_deliv']),
      returnToWarehouse: _parseInt(json['return_to_warehouse']),
      sentToVendor: _parseInt(json['sent_to_vendor']),
      hold: _parseInt(json['hold']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'drop_off': dropOff,
      'pickup': pickup,
      'sent_pickup': sentPickup,
      'pickup_complete': pickupComplete,
      'dispatch': dispatch,
      'rtv_dispatch': rtvDispatch,
      'arrived': arrived,
      'rtv_arrived': rtvArrived,
      'sent_for_deliv': sentForDeliv,
      'return_to_warehouse': returnToWarehouse,
      'sent_to_vendor': sentToVendor,
      'hold': hold,
    };
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
      createdOnDate: json['created_on__date']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      orders: _parseInt(json['orders']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'created_on__date': createdOnDate,
      'date': date,
      'orders': orders,
    };
  }
}

class OrderValueDataModel extends OrderValueDataEntity {
  const OrderValueDataModel({required super.createdOnDate, required super.cod});

  factory OrderValueDataModel.fromJson(Map<String, dynamic> json) {
    return OrderValueDataModel(
      createdOnDate: json['created_on__date']?.toString() ?? '',
      cod: _parseDouble(json['cod']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {'created_on__date': createdOnDate, 'cod': cod};
  }
}