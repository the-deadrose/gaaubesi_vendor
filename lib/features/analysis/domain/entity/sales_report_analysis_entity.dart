import 'package:equatable/equatable.dart';

class SalesReportAnalysis extends Equatable {
  final DateTime fromDate;
  final DateTime toDate;
  final int totalOrders;
  final int totalDeliveredOrders;
  final int totalReturnedOrders;
  final double totalSales;
  final double totalPackageValue;
  final List<DailySalesReport> dailyReports;

  const SalesReportAnalysis({
    required this.fromDate,
    required this.toDate,
    required this.totalOrders,
    required this.totalDeliveredOrders,
    required this.totalReturnedOrders,
    required this.totalSales,
    required this.totalPackageValue,
    required this.dailyReports,
  });

  @override
  List<Object?> get props => [
        fromDate,
        toDate,
        totalOrders,
        totalDeliveredOrders,
        totalReturnedOrders,
        totalSales,
        totalPackageValue,
        dailyReports,
      ];

  SalesReportAnalysis copyWith({
    DateTime? fromDate,
    DateTime? toDate,
    int? totalOrders,
    int? totalDeliveredOrders,
    int? totalReturnedOrders,
    double? totalSales,
    double? totalPackageValue,
    List<DailySalesReport>? dailyReports,
  }) {
    return SalesReportAnalysis(
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      totalOrders: totalOrders ?? this.totalOrders,
      totalDeliveredOrders: totalDeliveredOrders ?? this.totalDeliveredOrders,
      totalReturnedOrders: totalReturnedOrders ?? this.totalReturnedOrders,
      totalSales: totalSales ?? this.totalSales,
      totalPackageValue: totalPackageValue ?? this.totalPackageValue,
      dailyReports: dailyReports ?? this.dailyReports,
    );
  }
}

class DailySalesReport extends Equatable {
  final DateTime createdDate;
  final int totalOrders;
  final int deliveredOrders;
  final int returnedOrders;
  final double packageValue;
  final double sales;

  const DailySalesReport({
    required this.createdDate,
    required this.totalOrders,
    required this.deliveredOrders,
    required this.returnedOrders,
    required this.packageValue,
    required this.sales,
  });

  @override
  List<Object?> get props => [
        createdDate,
        totalOrders,
        deliveredOrders,
        returnedOrders,
        packageValue,
        sales,
      ];

  DailySalesReport copyWith({
    DateTime? createdDate,
    int? totalOrders,
    int? deliveredOrders,
    int? returnedOrders,
    double? packageValue,
    double? sales,
  }) {
    return DailySalesReport(
      createdDate: createdDate ?? this.createdDate,
      totalOrders: totalOrders ?? this.totalOrders,
      deliveredOrders: deliveredOrders ?? this.deliveredOrders,
      returnedOrders: returnedOrders ?? this.returnedOrders,
      packageValue: packageValue ?? this.packageValue,
      sales: sales ?? this.sales,
    );
  }
}