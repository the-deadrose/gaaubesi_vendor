import 'package:gaaubesi_vendor/features/analysis/domain/entity/delivery_report_analysis_entity.dart';

class DeliveryReportAnalysisModel extends DeliveryReportAnalysisEntity {
  DeliveryReportAnalysisModel({
    String? fromDate,
    String? toDate,
    int? totalDeliveredOrders,
    String? totalDeliveredValue,
    String? totalDeliveredCharge,
    int? totalReturnedOrders,
    String? totalReturnedValue,
    String? totalReturnedCharge,
    List<DailyReportModel>? dailyReports,
  }) : super(
         fromDate: fromDate ?? '',
         toDate: toDate ?? '',
         totalDeliveredOrders: totalDeliveredOrders ?? 0,
         totalDeliveredValue: totalDeliveredValue ?? '0',
         totalDeliveredCharge: totalDeliveredCharge ?? '0',
         totalReturnedOrders: totalReturnedOrders ?? 0,
         totalReturnedValue: totalReturnedValue ?? '0',
         totalReturnedCharge: totalReturnedCharge ?? '0',
         dailyReports: dailyReports ?? [],
       );

  factory DeliveryReportAnalysisModel.fromJson(Map<String, dynamic> json) {
    return DeliveryReportAnalysisModel(
      fromDate: json['from_date'] as String?,
      toDate: json['to_date'] as String?,
      totalDeliveredOrders: (json['total_delivered_orders'] as num?)?.toInt(),
      totalDeliveredValue: json['total_delivered_value'] as String?,
      totalDeliveredCharge: json['total_delivered_charge'] as String?,
      totalReturnedOrders: (json['total_returned_orders'] as num?)?.toInt(),
      totalReturnedValue: json['total_returned_value'] as String?,
      totalReturnedCharge: json['total_returned_charge'] as String?,
      dailyReports: (json['daily_reports'] as List<dynamic>?)
          ?.map((e) => DailyReportModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'from_date': fromDate.isEmpty ? null : fromDate,
    'to_date': toDate.isEmpty ? null : toDate,
    'total_delivered_orders': totalDeliveredOrders == 0
        ? null
        : totalDeliveredOrders,
    'total_delivered_value': totalDeliveredValue == '0'
        ? null
        : totalDeliveredValue,
    'total_delivered_charge': totalDeliveredCharge == '0'
        ? null
        : totalDeliveredCharge,
    'total_returned_orders': totalReturnedOrders == 0
        ? null
        : totalReturnedOrders,
    'total_returned_value': totalReturnedValue == '0'
        ? null
        : totalReturnedValue,
    'total_returned_charge': totalReturnedCharge == '0'
        ? null
        : totalReturnedCharge,
    'daily_reports': dailyReports.isEmpty ? null : dailyReports,
  };

  DeliveryReportAnalysisModel copyWith({
    String? fromDate,
    String? toDate,
    int? totalDeliveredOrders,
    String? totalDeliveredValue,
    String? totalDeliveredCharge,
    int? totalReturnedOrders,
    String? totalReturnedValue,
    String? totalReturnedCharge,
    List<DailyReportModel>? dailyReports,
  }) {
    return DeliveryReportAnalysisModel(
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      totalDeliveredOrders: totalDeliveredOrders ?? this.totalDeliveredOrders,
      totalDeliveredValue: totalDeliveredValue ?? this.totalDeliveredValue,
      totalDeliveredCharge: totalDeliveredCharge ?? this.totalDeliveredCharge,
      totalReturnedOrders: totalReturnedOrders ?? this.totalReturnedOrders,
      totalReturnedValue: totalReturnedValue ?? this.totalReturnedValue,
      totalReturnedCharge: totalReturnedCharge ?? this.totalReturnedCharge,
      dailyReports:
          dailyReports ?? List<DailyReportModel>.from(this.dailyReports),
    );
  }
}

class DailyReportModel extends DailyReportEntity {
  const DailyReportModel({
    String? deliveredDate,
    int? deliveredOrders,
    String? deliveredOrdersPackageValue,
    String? deliveredOrdersDeliveryCharge,
    int? returnedOrders,
    String? returnedOrdersPackageValue,
    String? returnedOrdersDeliveryCharge,
  }) : super(
         deliveredDate: deliveredDate ?? '',
         deliveredOrders: deliveredOrders ?? 0,
         deliveredOrdersPackageValue: deliveredOrdersPackageValue ?? '0',
         deliveredOrdersDeliveryCharge: deliveredOrdersDeliveryCharge ?? '0',
         returnedOrders: returnedOrders ?? 0,
         returnedOrdersPackageValue: returnedOrdersPackageValue ?? '0',
         returnedOrdersDeliveryCharge: returnedOrdersDeliveryCharge ?? '0',
       );

  factory DailyReportModel.fromJson(Map<String, dynamic> json) {
    return DailyReportModel(
      deliveredDate: json['delivered_date'] as String?,
      deliveredOrders: (json['delivered_orders'] as num?)?.toInt(),
      deliveredOrdersPackageValue:
          json['delivered_orders_package_value'] as String?,
      deliveredOrdersDeliveryCharge:
          json['delivered_orders_delivery_charge'] as String?,
      returnedOrders: (json['returned_orders'] as num?)?.toInt(),
      returnedOrdersPackageValue:
          json['returned_orders_package_value'] as String?,
      returnedOrdersDeliveryCharge:
          json['returned_orders_delivery_charge'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'delivered_date': deliveredDate.isEmpty ? null : deliveredDate,
    'delivered_orders': deliveredOrders == 0 ? null : deliveredOrders,
    'delivered_orders_package_value': deliveredOrdersPackageValue == '0'
        ? null
        : deliveredOrdersPackageValue,
    'delivered_orders_delivery_charge': deliveredOrdersDeliveryCharge == '0'
        ? null
        : deliveredOrdersDeliveryCharge,
    'returned_orders': returnedOrders == 0 ? null : returnedOrders,
    'returned_orders_package_value': returnedOrdersPackageValue == '0'
        ? null
        : returnedOrdersPackageValue,
    'returned_orders_delivery_charge': returnedOrdersDeliveryCharge == '0'
        ? null
        : returnedOrdersDeliveryCharge,
  };

  DailyReportModel copyWith({
    String? deliveredDate,
    int? deliveredOrders,
    String? deliveredOrdersPackageValue,
    String? deliveredOrdersDeliveryCharge,
    int? returnedOrders,
    String? returnedOrdersPackageValue,
    String? returnedOrdersDeliveryCharge,
  }) {
    return DailyReportModel(
      deliveredDate: deliveredDate ?? this.deliveredDate,
      deliveredOrders: deliveredOrders ?? this.deliveredOrders,
      deliveredOrdersPackageValue:
          deliveredOrdersPackageValue ?? this.deliveredOrdersPackageValue,
      deliveredOrdersDeliveryCharge:
          deliveredOrdersDeliveryCharge ?? this.deliveredOrdersDeliveryCharge,
      returnedOrders: returnedOrders ?? this.returnedOrders,
      returnedOrdersPackageValue:
          returnedOrdersPackageValue ?? this.returnedOrdersPackageValue,
      returnedOrdersDeliveryCharge:
          returnedOrdersDeliveryCharge ?? this.returnedOrdersDeliveryCharge,
    );
  }
}
