import 'package:gaaubesi_vendor/features/analysis/domain/entity/sales_report_analysis_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sales_report_analysis_model.g.dart';

@JsonSerializable()
class SalesReportAnalysisModel {
  @JsonKey(name: 'from_date')
  final String? fromDate;

  @JsonKey(name: 'to_date')
  final String? toDate;

  @JsonKey(name: 'total_orders')
  final int? totalOrders;

  @JsonKey(name: 'total_delivered_orders')
  final int? totalDeliveredOrders;

  @JsonKey(name: 'total_returned_orders')
  final int? totalReturnedOrders;

  @JsonKey(name: 'total_sales')
  final String? totalSales;

  @JsonKey(name: 'total_package_value')
  final String? totalPackageValue;

  @JsonKey(name: 'daily_reports')
  final List<DailySalesReportModel>? dailyReports;

  SalesReportAnalysisModel({
    this.fromDate,
    this.toDate,
    this.totalOrders,
    this.totalDeliveredOrders,
    this.totalReturnedOrders,
    this.totalSales,
    this.totalPackageValue,
    this.dailyReports,
  });

  factory SalesReportAnalysisModel.fromJson(Map<String, dynamic> json) =>
      _$SalesReportAnalysisModelFromJson(json);

  Map<String, dynamic> toJson() => _$SalesReportAnalysisModelToJson(this);

  SalesReportAnalysis toEntity() {
    return SalesReportAnalysis(
      fromDate: fromDate != null ? DateTime.parse(fromDate!) : DateTime.now(),
      toDate: toDate != null ? DateTime.parse(toDate!) : DateTime.now(),
      totalOrders: totalOrders ?? 0,
      totalDeliveredOrders: totalDeliveredOrders ?? 0,
      totalReturnedOrders: totalReturnedOrders ?? 0,
      totalSales: _parseDouble(totalSales ?? '0'),
      totalPackageValue: _parseDouble(totalPackageValue ?? '0'),
      dailyReports: (dailyReports ?? []).map((model) => model.toEntity()).toList(),
    );
  }

  static double _parseDouble(String value) {
    return double.tryParse(value.replaceAll('"', '')) ?? 0.0;
  }
}

@JsonSerializable()
class DailySalesReportModel {
  @JsonKey(name: 'created_date')
  final String? createdDate;

  @JsonKey(name: 'total_orders')
  final int? totalOrders;

  @JsonKey(name: 'delivered_orders')
  final int? deliveredOrders;

  @JsonKey(name: 'returned_orders')
  final int? returnedOrders;

  @JsonKey(name: 'package_value')
  final String? packageValue;

  @JsonKey(name: 'sales')
  final String? sales;

  DailySalesReportModel({
    this.createdDate,
    this.totalOrders,
    this.deliveredOrders,
    this.returnedOrders,
    this.packageValue,
    this.sales,
  });

  factory DailySalesReportModel.fromJson(Map<String, dynamic> json) =>
      _$DailySalesReportModelFromJson(json);

  Map<String, dynamic> toJson() => _$DailySalesReportModelToJson(this);

  DailySalesReport toEntity() {
    return DailySalesReport(
      createdDate: createdDate != null ? DateTime.parse(createdDate!) : DateTime.now(),
      totalOrders: totalOrders ?? 0,
      deliveredOrders: deliveredOrders ?? 0,
      returnedOrders: returnedOrders ?? 0,
      packageValue: SalesReportAnalysisModel._parseDouble(packageValue ?? '0'),
      sales: SalesReportAnalysisModel._parseDouble(sales ?? '0'),
    );
  }
}
