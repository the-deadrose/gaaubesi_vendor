import 'package:gaaubesi_vendor/features/home/domain/entities/vendor_stats_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vendor_stats_model.g.dart';

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    return parsed ?? 0.0;
  }
  return 0.0;
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    return parsed ?? 0;
  }
  return 0;
}

String _parseString(dynamic value) => value?.toString() ?? '';

ReturnedPackagesModel _parseReturnedPackages(dynamic value) {
  if (value is Map<String, dynamic>) {
    return ReturnedPackagesModel.fromJson(value);
  }
  return const ReturnedPackagesModel(count: 0, value: 0.0);
}

ProcessingOrdersModel _parseProcessingOrders(dynamic value) {
  if (value is Map<String, dynamic>) {
    return ProcessingOrdersModel.fromJson(value);
  }
  return const ProcessingOrdersModel(
    dropOff: 0,
    pickup: 0,
    sentPickup: 0,
    pickupComplete: 0,
    dispatch: 0,
    rtvDispatch: 0,
    arrived: 0,
    rtvArrived: 0,
    sentForDeliv: 0,
    returnToWarehouse: 0,
    sentToVendor: 0,
    hold: 0,
  );
}

List<OrderDataModel> _parseOrderList(dynamic value) {
  if (value == null) return const [];
  if (value is! List) return const [];
  return value
      .whereType<Map<String, dynamic>>()
      .map((e) => OrderDataModel.fromJson(e))
      .toList();
}

List<OrderValueDataModel> _parseOrderValueList(dynamic value) {
  if (value == null) return const [];
  if (value is! List) return const [];
  return value
      .whereType<Map<String, dynamic>>()
      .map((e) => OrderValueDataModel.fromJson(e))
      .toList();
}

Map<String, dynamic> _returnedPackagesToJson(ReturnedPackagesEntity value) {
  return {'count': value.count, 'value': value.value};
}

Map<String, dynamic> _processingOrdersToJson(ProcessingOrdersEntity value) {
  return {
    'drop_off': value.dropOff,
    'pickup': value.pickup,
    'sent_pickup': value.sentPickup,
    'pickup_complete': value.pickupComplete,
    'dispatch': value.dispatch,
    'rtv_dispatch': value.rtvDispatch,
    'arrived': value.arrived,
    'rtv_arrived': value.rtvArrived,
    'sent_for_deliv': value.sentForDeliv,
    'return_to_warehouse': value.returnToWarehouse,
    'sent_to_vendor': value.sentToVendor,
    'hold': value.hold,
  };
}

List<Map<String, dynamic>> _orderListToJson(List<OrderDataEntity> value) {
  return value.map((e) => {
    'created_on__date': e.createdOnDate,
    'date': e.date,
    'orders': e.orders,
  }).toList();
}

List<Map<String, dynamic>> _orderValueListToJson(List<OrderValueDataEntity> value) {
  return value.map((e) => {
    'created_on__date': e.createdOnDate,
    'cod': e.cod,
  }).toList();
}

@JsonSerializable()
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

  @override
  @JsonKey(name: 'vendor_name', fromJson: _parseString)
  String get vendorName => super.vendorName;

  @override
  @JsonKey(name: 'success_percent', fromJson: _parseDouble)
  double get successPercent => super.successPercent;

  @override
  @JsonKey(name: 'return_percent', fromJson: _parseDouble)
  double get returnPercent => super.returnPercent;

  @override
  @JsonKey(name: 'stale_orders', fromJson: _parseInt)
  int get staleOrders => super.staleOrders;

  @override
  @JsonKey(name: 'todays_comment', fromJson: _parseInt)
  int get todaysComment => super.todaysComment;

  @override
  @JsonKey(name: 'orders_in_process', fromJson: _parseInt)
  int get ordersInProcess => super.ordersInProcess;

  @override
  @JsonKey(name: 'orders_in_process_val', fromJson: _parseDouble)
  double get ordersInProcessVal => super.ordersInProcessVal;

  @override
  @JsonKey(name: 'orders_in_return_process', fromJson: _parseInt)
  int get ordersInReturnProcess => super.ordersInReturnProcess;

  @override
  @JsonKey(name: 'orders_in_delivery_process', fromJson: _parseInt)
  int get ordersInDeliveryProcess => super.ordersInDeliveryProcess;

  @override
  @JsonKey(name: 'total_delv_charge', fromJson: _parseDouble)
  double get totalDelvCharge => super.totalDelvCharge;

  @override
  @JsonKey(name: 'total_packages', fromJson: _parseInt)
  int get totalPackages => super.totalPackages;

  @override
  @JsonKey(name: 'delivered_packages', fromJson: _parseInt)
  int get deliveredPackages => super.deliveredPackages;

  @override
  @JsonKey(name: 'total_packages_value', fromJson: _parseDouble)
  double get totalPackagesValue => super.totalPackagesValue;

  @override
  @JsonKey(name: 'delivered_packages_value', fromJson: _parseDouble)
  double get deliveredPackagesValue => super.deliveredPackagesValue;

  @override
  @JsonKey(name: 'pending_cod', fromJson: _parseDouble)
  double get pendingCod => super.pendingCod;

  @override
  @JsonKey(name: 'total_rtv_order', fromJson: _parseInt)
  int get totalRtvOrder => super.totalRtvOrder;

  @override
  @JsonKey(name: 'total_hold_order', fromJson: _parseInt)
  int get totalHoldOrder => super.totalHoldOrder;

  @override
  @JsonKey(name: 'today_delivery', fromJson: _parseInt)
  int get todayDelivery => super.todayDelivery;

  @override
  @JsonKey(name: 'redirect_percentage', fromJson: _parseDouble)
  double get redirectPercentage => super.redirectPercentage;

  @override
  @JsonKey(name: 'todays_returned_delivery', fromJson: _parseInt)
  int get todaysReturnedDelivery => super.todaysReturnedDelivery;

  @override
  @JsonKey(name: 'redirect_order_returned_percent', fromJson: _parseDouble)
  double get redirectOrderReturnedPercent => super.redirectOrderReturnedPercent;

  @override
  @JsonKey(name: 'total_redirect_percent', fromJson: _parseDouble)
  double get totalRedirectPercent => super.totalRedirectPercent;

  @override
  @JsonKey(name: 'incoming_returns', fromJson: _parseInt)
  int get incomingReturns => super.incomingReturns;

  @override
  @JsonKey(name: 'today_order_created', fromJson: _parseInt)
  int get todayOrderCreated => super.todayOrderCreated;

  @override
  @JsonKey(
    name: 'true_returned_packages',
    fromJson: _parseReturnedPackages,
    toJson: _returnedPackagesToJson,
  )
  ReturnedPackagesEntity get trueReturnedPackages => super.trueReturnedPackages;

  @override
  @JsonKey(
    name: 'false_returned_packages',
    fromJson: _parseReturnedPackages,
    toJson: _returnedPackagesToJson,
  )
  ReturnedPackagesEntity get falseReturnedPackages => super.falseReturnedPackages;

  @override
  @JsonKey(
    name: 'processing_orders',
    fromJson: _parseProcessingOrders,
    toJson: _processingOrdersToJson,
  )
  ProcessingOrdersEntity get processingOrders => super.processingOrders;

  @override
  @JsonKey(
    name: 'order_thirty_days',
    fromJson: _parseOrderList,
    toJson: _orderListToJson,
  )
  List<OrderDataEntity> get orderThirtyDays => super.orderThirtyDays;

  @override
  @JsonKey(
    name: 'order_value_thirty_days',
    fromJson: _parseOrderValueList,
    toJson: _orderValueListToJson,
  )
  List<OrderValueDataEntity> get orderValueThirtyDays => super.orderValueThirtyDays;

  @override
  @JsonKey(name: 'last_cod_amount', fromJson: _parseDouble)
  double get lastCodAmount => super.lastCodAmount;

  @override
  @JsonKey(name: 'lasst_cod_date', fromJson: _parseString)
  String get lasstCodDate => super.lasstCodDate;

  factory VendorStatsModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data;
    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      data = json['data'] as Map<String, dynamic>;
    } else {
      data = json;
    }
    return _$VendorStatsModelFromJson(data);
  }

  Map<String, dynamic> toJson() => _$VendorStatsModelToJson(this);
}

@JsonSerializable()
class ReturnedPackagesModel extends ReturnedPackagesEntity {
  const ReturnedPackagesModel({required super.count, required super.value});

  @override
  @JsonKey(fromJson: _parseInt)
  int get count => super.count;

  @override
  @JsonKey(fromJson: _parseDouble)
  double get value => super.value;

  factory ReturnedPackagesModel.fromJson(Map<String, dynamic> json) =>
      _$ReturnedPackagesModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReturnedPackagesModelToJson(this);
}

@JsonSerializable()
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

  @override
  @JsonKey(name: 'drop_off', fromJson: _parseInt)
  int get dropOff => super.dropOff;

  @override
  @JsonKey(fromJson: _parseInt)
  int get pickup => super.pickup;

  @override
  @JsonKey(name: 'sent_pickup', fromJson: _parseInt)
  int get sentPickup => super.sentPickup;

  @override
  @JsonKey(name: 'pickup_complete', fromJson: _parseInt)
  int get pickupComplete => super.pickupComplete;

  @override
  @JsonKey(fromJson: _parseInt)
  int get dispatch => super.dispatch;

  @override
  @JsonKey(name: 'rtv_dispatch', fromJson: _parseInt)
  int get rtvDispatch => super.rtvDispatch;

  @override
  @JsonKey(fromJson: _parseInt)
  int get arrived => super.arrived;

  @override
  @JsonKey(name: 'rtv_arrived', fromJson: _parseInt)
  int get rtvArrived => super.rtvArrived;

  @override
  @JsonKey(name: 'sent_for_deliv', fromJson: _parseInt)
  int get sentForDeliv => super.sentForDeliv;

  @override
  @JsonKey(name: 'return_to_warehouse', fromJson: _parseInt)
  int get returnToWarehouse => super.returnToWarehouse;

  @override
  @JsonKey(name: 'sent_to_vendor', fromJson: _parseInt)
  int get sentToVendor => super.sentToVendor;

  @override
  @JsonKey(fromJson: _parseInt)
  int get hold => super.hold;

  factory ProcessingOrdersModel.fromJson(Map<String, dynamic> json) =>
      _$ProcessingOrdersModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProcessingOrdersModelToJson(this);
}

@JsonSerializable()
class OrderDataModel extends OrderDataEntity {
  const OrderDataModel({
    required super.createdOnDate,
    required super.date,
    required super.orders,
  });

  @override
  @JsonKey(name: 'created_on__date', fromJson: _parseString)
  String get createdOnDate => super.createdOnDate;

  @override
  @JsonKey(fromJson: _parseString)
  String get date => super.date;

  @override
  @JsonKey(fromJson: _parseInt)
  int get orders => super.orders;

  factory OrderDataModel.fromJson(Map<String, dynamic> json) =>
      _$OrderDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDataModelToJson(this);
}

@JsonSerializable()
class OrderValueDataModel extends OrderValueDataEntity {
  const OrderValueDataModel({required super.createdOnDate, required super.cod});

  @override
  @JsonKey(name: 'created_on__date', fromJson: _parseString)
  String get createdOnDate => super.createdOnDate;

  @override
  @JsonKey(fromJson: _parseDouble)
  double get cod => super.cod;

  factory OrderValueDataModel.fromJson(Map<String, dynamic> json) =>
      _$OrderValueDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderValueDataModelToJson(this);
}
