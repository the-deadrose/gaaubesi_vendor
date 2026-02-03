import 'package:gaaubesi_vendor/features/analysis/domain/entity/delivery_report_analysis_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'delivery_report_analysis_model.g.dart';

@JsonSerializable(createToJson: true, explicitToJson: true)
class DeliveryReportAnalysisModel extends DeliveryReportAnalysisEntity {
  @JsonKey(name: 'from_date')
  @override
  final String fromDate;

  @JsonKey(name: 'to_date')
  @override
  final String toDate;

  @JsonKey(name: 'total_delivered_orders')
  @override
  final int totalDeliveredOrders;

  @JsonKey(name: 'total_delivered_value')
  @override
  final String totalDeliveredValue;

  @JsonKey(name: 'total_delivered_charge')
  @override
  final String totalDeliveredCharge;

  @JsonKey(name: 'total_returned_orders')
  @override
  final int totalReturnedOrders;

  @JsonKey(name: 'total_returned_value')
  @override
  final String totalReturnedValue;

  @JsonKey(name: 'total_returned_charge')
  @override
  final String totalReturnedCharge;

  @JsonKey(name: 'daily_reports')
  @override
  final List<DailyReportModel> dailyReports;

  const DeliveryReportAnalysisModel({
    required this.fromDate,
    required this.toDate,
    required this.totalDeliveredOrders,
    required this.totalDeliveredValue,
    required this.totalDeliveredCharge,
    required this.totalReturnedOrders,
    required this.totalReturnedValue,
    required this.totalReturnedCharge,
    required this.dailyReports,
  }) : super(
          fromDate: fromDate,
          toDate: toDate,
          totalDeliveredOrders: totalDeliveredOrders,
          totalDeliveredValue: totalDeliveredValue,
          totalDeliveredCharge: totalDeliveredCharge,
          totalReturnedOrders: totalReturnedOrders,
          totalReturnedValue: totalReturnedValue,
          totalReturnedCharge: totalReturnedCharge,
          dailyReports: dailyReports,
        );

  // Factory constructor for JSON deserialization
  factory DeliveryReportAnalysisModel.fromJson(Map<String, dynamic> json) =>
      _$DeliveryReportAnalysisModelFromJson(json);

  // JSON serialization method
  Map<String, dynamic> toJson() => _$DeliveryReportAnalysisModelToJson(this);

  // Copy with method for immutability
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
      dailyReports: dailyReports ?? this.dailyReports,
    );
  }
}

@JsonSerializable(createToJson: true)
class DailyReportModel extends DailyReportEntity {
  @JsonKey(name: 'delivered_date')
  @override
  final String deliveredDate;

  @JsonKey(name: 'delivered_orders')
  @override
  final int deliveredOrders;

  @JsonKey(name: 'delivered_orders_package_value')
  @override
  final String deliveredOrdersPackageValue;

  @JsonKey(name: 'delivered_orders_delivery_charge')
  @override
  final String deliveredOrdersDeliveryCharge;

  @JsonKey(name: 'returned_orders')
  @override
  final int returnedOrders;

  @JsonKey(name: 'returned_orders_package_value')
  @override
  final String returnedOrdersPackageValue;

  @JsonKey(name: 'returned_orders_delivery_charge')
  @override
  final String returnedOrdersDeliveryCharge;

  const DailyReportModel({
    required this.deliveredDate,
    required this.deliveredOrders,
    required this.deliveredOrdersPackageValue,
    required this.deliveredOrdersDeliveryCharge,
    required this.returnedOrders,
    required this.returnedOrdersPackageValue,
    required this.returnedOrdersDeliveryCharge,
  }) : super(
          deliveredDate: deliveredDate,
          deliveredOrders: deliveredOrders,
          deliveredOrdersPackageValue: deliveredOrdersPackageValue,
          deliveredOrdersDeliveryCharge: deliveredOrdersDeliveryCharge,
          returnedOrders: returnedOrders,
          returnedOrdersPackageValue: returnedOrdersPackageValue,
          returnedOrdersDeliveryCharge: returnedOrdersDeliveryCharge,
        );

  // Factory constructor for JSON deserialization
  factory DailyReportModel.fromJson(Map<String, dynamic> json) =>
      _$DailyReportModelFromJson(json);

  // JSON serialization method
  Map<String, dynamic> toJson() => _$DailyReportModelToJson(this);

  // Copy with method for immutability
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
