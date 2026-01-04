// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VendorStatsModel _$VendorStatsModelFromJson(
  Map<String, dynamic> json,
) => VendorStatsModel(
  vendorName: _parseString(json['vendor_name']),
  successPercent: _parseDouble(json['success_percent']),
  returnPercent: _parseDouble(json['return_percent']),
  staleOrders: _parseInt(json['stale_orders']),
  todaysComment: _parseInt(json['todays_comment']),
  ordersInProcess: _parseInt(json['orders_in_process']),
  ordersInProcessVal: _parseDouble(json['orders_in_process_val']),
  ordersInReturnProcess: _parseInt(json['orders_in_return_process']),
  ordersInDeliveryProcess: _parseInt(json['orders_in_delivery_process']),
  totalDelvCharge: _parseDouble(json['total_delv_charge']),
  totalPackages: _parseInt(json['total_packages']),
  deliveredPackages: _parseInt(json['delivered_packages']),
  totalPackagesValue: _parseDouble(json['total_packages_value']),
  deliveredPackagesValue: _parseDouble(json['delivered_packages_value']),
  pendingCod: _parseDouble(json['pending_cod']),
  totalRtvOrder: _parseInt(json['total_rtv_order']),
  totalHoldOrder: _parseInt(json['total_hold_order']),
  todayDelivery: _parseInt(json['today_delivery']),
  redirectPercentage: _parseDouble(json['redirect_percentage']),
  todaysReturnedDelivery: _parseInt(json['todays_returned_delivery']),
  redirectOrderReturnedPercent: _parseDouble(
    json['redirect_order_returned_percent'],
  ),
  totalRedirectPercent: _parseDouble(json['total_redirect_percent']),
  incomingReturns: _parseInt(json['incoming_returns']),
  todayOrderCreated: _parseInt(json['today_order_created']),
  trueReturnedPackages: _parseReturnedPackages(json['true_returned_packages']),
  falseReturnedPackages: _parseReturnedPackages(
    json['false_returned_packages'],
  ),
  processingOrders: _parseProcessingOrders(json['processing_orders']),
  orderThirtyDays: _parseOrderList(json['order_thirty_days']),
  orderValueThirtyDays: _parseOrderValueList(json['order_value_thirty_days']),
  lastCodAmount: _parseDouble(json['last_cod_amount']),
  lasstCodDate: _parseString(json['lasst_cod_date']),
);

Map<String, dynamic> _$VendorStatsModelToJson(VendorStatsModel instance) =>
    <String, dynamic>{
      'vendor_name': instance.vendorName,
      'success_percent': instance.successPercent,
      'return_percent': instance.returnPercent,
      'stale_orders': instance.staleOrders,
      'todays_comment': instance.todaysComment,
      'orders_in_process': instance.ordersInProcess,
      'orders_in_process_val': instance.ordersInProcessVal,
      'orders_in_return_process': instance.ordersInReturnProcess,
      'orders_in_delivery_process': instance.ordersInDeliveryProcess,
      'total_delv_charge': instance.totalDelvCharge,
      'total_packages': instance.totalPackages,
      'delivered_packages': instance.deliveredPackages,
      'total_packages_value': instance.totalPackagesValue,
      'delivered_packages_value': instance.deliveredPackagesValue,
      'pending_cod': instance.pendingCod,
      'total_rtv_order': instance.totalRtvOrder,
      'total_hold_order': instance.totalHoldOrder,
      'today_delivery': instance.todayDelivery,
      'redirect_percentage': instance.redirectPercentage,
      'todays_returned_delivery': instance.todaysReturnedDelivery,
      'redirect_order_returned_percent': instance.redirectOrderReturnedPercent,
      'total_redirect_percent': instance.totalRedirectPercent,
      'incoming_returns': instance.incomingReturns,
      'today_order_created': instance.todayOrderCreated,
      'true_returned_packages': _returnedPackagesToJson(
        instance.trueReturnedPackages,
      ),
      'false_returned_packages': _returnedPackagesToJson(
        instance.falseReturnedPackages,
      ),
      'processing_orders': _processingOrdersToJson(instance.processingOrders),
      'order_thirty_days': _orderListToJson(instance.orderThirtyDays),
      'order_value_thirty_days': _orderValueListToJson(
        instance.orderValueThirtyDays,
      ),
      'last_cod_amount': instance.lastCodAmount,
      'lasst_cod_date': instance.lasstCodDate,
    };

ReturnedPackagesModel _$ReturnedPackagesModelFromJson(
  Map<String, dynamic> json,
) => ReturnedPackagesModel(
  count: _parseInt(json['count']),
  value: _parseDouble(json['value']),
);

Map<String, dynamic> _$ReturnedPackagesModelToJson(
  ReturnedPackagesModel instance,
) => <String, dynamic>{'count': instance.count, 'value': instance.value};

ProcessingOrdersModel _$ProcessingOrdersModelFromJson(
  Map<String, dynamic> json,
) => ProcessingOrdersModel(
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

Map<String, dynamic> _$ProcessingOrdersModelToJson(
  ProcessingOrdersModel instance,
) => <String, dynamic>{
  'drop_off': instance.dropOff,
  'pickup': instance.pickup,
  'sent_pickup': instance.sentPickup,
  'pickup_complete': instance.pickupComplete,
  'dispatch': instance.dispatch,
  'rtv_dispatch': instance.rtvDispatch,
  'arrived': instance.arrived,
  'rtv_arrived': instance.rtvArrived,
  'sent_for_deliv': instance.sentForDeliv,
  'return_to_warehouse': instance.returnToWarehouse,
  'sent_to_vendor': instance.sentToVendor,
  'hold': instance.hold,
};

OrderDataModel _$OrderDataModelFromJson(Map<String, dynamic> json) =>
    OrderDataModel(
      createdOnDate: _parseString(json['created_on__date']),
      date: _parseString(json['date']),
      orders: _parseInt(json['orders']),
    );

Map<String, dynamic> _$OrderDataModelToJson(OrderDataModel instance) =>
    <String, dynamic>{
      'created_on__date': instance.createdOnDate,
      'date': instance.date,
      'orders': instance.orders,
    };

OrderValueDataModel _$OrderValueDataModelFromJson(Map<String, dynamic> json) =>
    OrderValueDataModel(
      createdOnDate: _parseString(json['created_on__date']),
      cod: _parseDouble(json['cod']),
    );

Map<String, dynamic> _$OrderValueDataModelToJson(
  OrderValueDataModel instance,
) => <String, dynamic>{
  'created_on__date': instance.createdOnDate,
  'cod': instance.cod,
};
