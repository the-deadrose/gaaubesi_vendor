// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_report_analysis_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalesReportAnalysisModel _$SalesReportAnalysisModelFromJson(
  Map<String, dynamic> json,
) => SalesReportAnalysisModel(
  fromDate: json['from_date'] as String?,
  toDate: json['to_date'] as String?,
  totalOrders: (json['total_orders'] as num?)?.toInt(),
  totalDeliveredOrders: (json['total_delivered_orders'] as num?)?.toInt(),
  totalReturnedOrders: (json['total_returned_orders'] as num?)?.toInt(),
  totalSales: json['total_sales'] as String?,
  totalPackageValue: json['total_package_value'] as String?,
  dailyReports: (json['daily_reports'] as List<dynamic>?)
      ?.map((e) => DailySalesReportModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SalesReportAnalysisModelToJson(
  SalesReportAnalysisModel instance,
) => <String, dynamic>{
  'from_date': instance.fromDate,
  'to_date': instance.toDate,
  'total_orders': instance.totalOrders,
  'total_delivered_orders': instance.totalDeliveredOrders,
  'total_returned_orders': instance.totalReturnedOrders,
  'total_sales': instance.totalSales,
  'total_package_value': instance.totalPackageValue,
  'daily_reports': instance.dailyReports,
};

DailySalesReportModel _$DailySalesReportModelFromJson(
  Map<String, dynamic> json,
) => DailySalesReportModel(
  createdDate: json['created_date'] as String?,
  totalOrders: (json['total_orders'] as num?)?.toInt(),
  deliveredOrders: (json['delivered_orders'] as num?)?.toInt(),
  returnedOrders: (json['returned_orders'] as num?)?.toInt(),
  packageValue: json['package_value'] as String?,
  sales: json['sales'] as String?,
);

Map<String, dynamic> _$DailySalesReportModelToJson(
  DailySalesReportModel instance,
) => <String, dynamic>{
  'created_date': instance.createdDate,
  'total_orders': instance.totalOrders,
  'delivered_orders': instance.deliveredOrders,
  'returned_orders': instance.returnedOrders,
  'package_value': instance.packageValue,
  'sales': instance.sales,
};
