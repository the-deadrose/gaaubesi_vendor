// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_report_analysis_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryReportAnalysisModel _$DeliveryReportAnalysisModelFromJson(
  Map<String, dynamic> json,
) => DeliveryReportAnalysisModel(
  fromDate: json['from_date'] as String,
  toDate: json['to_date'] as String,
  totalDeliveredOrders: (json['total_delivered_orders'] as num).toInt(),
  totalDeliveredValue: json['total_delivered_value'] as String,
  totalDeliveredCharge: json['total_delivered_charge'] as String,
  totalReturnedOrders: (json['total_returned_orders'] as num).toInt(),
  totalReturnedValue: json['total_returned_value'] as String,
  totalReturnedCharge: json['total_returned_charge'] as String,
  dailyReports: (json['daily_reports'] as List<dynamic>)
      .map((e) => DailyReportModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DeliveryReportAnalysisModelToJson(
  DeliveryReportAnalysisModel instance,
) => <String, dynamic>{
  'from_date': instance.fromDate,
  'to_date': instance.toDate,
  'total_delivered_orders': instance.totalDeliveredOrders,
  'total_delivered_value': instance.totalDeliveredValue,
  'total_delivered_charge': instance.totalDeliveredCharge,
  'total_returned_orders': instance.totalReturnedOrders,
  'total_returned_value': instance.totalReturnedValue,
  'total_returned_charge': instance.totalReturnedCharge,
  'daily_reports': instance.dailyReports.map((e) => e.toJson()).toList(),
};

DailyReportModel _$DailyReportModelFromJson(
  Map<String, dynamic> json,
) => DailyReportModel(
  deliveredDate: json['delivered_date'] as String,
  deliveredOrders: (json['delivered_orders'] as num).toInt(),
  deliveredOrdersPackageValue: json['delivered_orders_package_value'] as String,
  deliveredOrdersDeliveryCharge:
      json['delivered_orders_delivery_charge'] as String,
  returnedOrders: (json['returned_orders'] as num).toInt(),
  returnedOrdersPackageValue: json['returned_orders_package_value'] as String,
  returnedOrdersDeliveryCharge:
      json['returned_orders_delivery_charge'] as String,
);

Map<String, dynamic> _$DailyReportModelToJson(
  DailyReportModel instance,
) => <String, dynamic>{
  'delivered_date': instance.deliveredDate,
  'delivered_orders': instance.deliveredOrders,
  'delivered_orders_package_value': instance.deliveredOrdersPackageValue,
  'delivered_orders_delivery_charge': instance.deliveredOrdersDeliveryCharge,
  'returned_orders': instance.returnedOrders,
  'returned_orders_package_value': instance.returnedOrdersPackageValue,
  'returned_orders_delivery_charge': instance.returnedOrdersDeliveryCharge,
};
