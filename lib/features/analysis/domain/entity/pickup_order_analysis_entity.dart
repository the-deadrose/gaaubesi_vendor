import 'package:equatable/equatable.dart';

class PickupOrderAnalysisEntity extends Equatable {
  final String fromDate;
  final String toDate;
  final int totalOrders;
  final List<DailyOrderCountEntity> dailyCounts;

  const PickupOrderAnalysisEntity({
    required this.fromDate,
    required this.toDate,
    required this.totalOrders,
    required this.dailyCounts,
  });

  @override
  List<Object?> get props => [fromDate, toDate, totalOrders, dailyCounts];

  @override
  bool? get stringify => true;
}

class DailyOrderCountEntity extends Equatable {
  final String date;
  final int count;
  final List<String> orderIds;

  const DailyOrderCountEntity({
    required this.date,
    required this.count,
    required this.orderIds,
  });

  @override
  List<Object?> get props => [date, count, orderIds];
}
