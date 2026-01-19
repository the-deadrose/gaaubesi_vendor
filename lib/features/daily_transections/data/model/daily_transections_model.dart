import 'package:gaaubesi_vendor/features/daily_transections/domain/entity/daily_transections_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_transections_model.g.dart';


int _intFromJson(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

String _stringFromJson(dynamic value) {
  return value?.toString() ?? '';
}

DateTime _dateTimeFromJson(dynamic value) {
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
}



@JsonSerializable()
class DailyTransectionsModel {
  @JsonKey(fromJson: _stringFromJson)
  final String date;

  @JsonKey(name: 'delivered_orders')
  final List<DailyOrderModel> deliveredOrders;

  @JsonKey(name: 'returned_orders')
  final List<DailyOrderModel> returnedOrders;

  @JsonKey(name: 'cod_transfer_total', fromJson: _stringFromJson)
  final String codTransferTotal;

  @JsonKey(name: 'delivered_orders_count', fromJson: _intFromJson)
  final int deliveredOrdersCount;

  @JsonKey(name: 'returned_orders_count', fromJson: _intFromJson)
  final int returnedOrdersCount;

  @JsonKey(name: 'total_cod_charge_delivered', fromJson: _stringFromJson)
  final String totalCodChargeDelivered;

  @JsonKey(name: 'total_delivery_charge_delivered', fromJson: _stringFromJson)
  final String totalDeliveryChargeDelivered;

  @JsonKey(name: 'total_cod_charge_returned', fromJson: _stringFromJson)
  final String totalCodChargeReturned;

  @JsonKey(name: 'total_delivery_charge_returned', fromJson: _stringFromJson)
  final String totalDeliveryChargeReturned;

  const DailyTransectionsModel({
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

  factory DailyTransectionsModel.fromJson(Map<String, dynamic> json) =>
      _$DailyTransectionsModelFromJson(json);

  Map<String, dynamic> toJson() => _$DailyTransectionsModelToJson(this);


  DailyTransections toEntity() {
    return DailyTransections(
      date: date,
      deliveredOrders:
          deliveredOrders.map((e) => e.toEntity()).toList(),
      returnedOrders:
          returnedOrders.map((e) => e.toEntity()).toList(),
      codTransferTotal: codTransferTotal,
      deliveredOrdersCount: deliveredOrdersCount,
      returnedOrdersCount: returnedOrdersCount,
      totalCodChargeDelivered: totalCodChargeDelivered,
      totalDeliveryChargeDelivered: totalDeliveryChargeDelivered,
      totalCodChargeReturned: totalCodChargeReturned,
      totalDeliveryChargeReturned: totalDeliveryChargeReturned,
    );
  }
}



@JsonSerializable()
class DailyOrderModel {
  @JsonKey(name: 'order_id', fromJson: _intFromJson)
  final int orderId;

  @JsonKey(name: 'cod_charge', fromJson: _stringFromJson)
  final String codCharge;

  @JsonKey(name: 'delivery_charge', fromJson: _stringFromJson)
  final String deliveryCharge;

  @JsonKey(name: 'delivered_date', fromJson: _dateTimeFromJson)
  final DateTime deliveredDate;

  @JsonKey(name: 'delivered_date_formatted', fromJson: _stringFromJson)
  final String deliveredDateFormatted;

  const DailyOrderModel({
    required this.orderId,
    required this.codCharge,
    required this.deliveryCharge,
    required this.deliveredDate,
    required this.deliveredDateFormatted,
  });

  factory DailyOrderModel.fromJson(Map<String, dynamic> json) =>
      _$DailyOrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$DailyOrderModelToJson(this);

  DailyOrder toEntity() {
    return DailyOrder(
      orderId: orderId,
      codCharge: codCharge,
      deliveryCharge: deliveryCharge,
      deliveredDate: deliveredDate,
      deliveredDateFormatted: deliveredDateFormatted,
    );
  }
}
