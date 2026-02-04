import 'dart:convert';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/pickup_order_analysis_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pickup_order_analysis_model.g.dart';

@JsonSerializable()
class PickupOrderAnalysisModel {
  @JsonKey(name: 'from_date')
  final String? fromDate;

  @JsonKey(name: 'to_date')
  final String? toDate;

  @JsonKey(name: 'total_orders')
  final int? totalOrders;

  @JsonKey(name: 'daily_counts')
  final List<DailyOrderCountModel>? dailyCounts;

  PickupOrderAnalysisModel({
    this.fromDate,
    this.toDate,
    this.totalOrders,
    this.dailyCounts,
  });

  factory PickupOrderAnalysisModel.fromJson(Map<String, dynamic> json) =>
      _$PickupOrderAnalysisModelFromJson(json);

  Map<String, dynamic> toJson() => _$PickupOrderAnalysisModelToJson(this);

  PickupOrderAnalysisEntity toEntity() => PickupOrderAnalysisEntity(
    fromDate: fromDate ?? '',
    toDate: toDate ?? '',
    totalOrders: totalOrders ?? 0,
    dailyCounts: (dailyCounts ?? []).map((e) => e.toEntity()).toList(),
  );

  factory PickupOrderAnalysisModel.fromRawJson(String jsonString) =>
      PickupOrderAnalysisModel.fromJson(
        json.decode(jsonString) as Map<String, dynamic>,
      );

  String toRawJson() => json.encode(toJson());
}

@JsonSerializable()
class DailyOrderCountModel {
  final String? date;
  final int? count;

  @JsonKey(name: 'order_ids')
  final List<String>? orderIds;

  DailyOrderCountModel({
    this.date,
    this.count,
    this.orderIds,
  });

  factory DailyOrderCountModel.fromJson(Map<String, dynamic> json) =>
      _$DailyOrderCountModelFromJson(json);

  Map<String, dynamic> toJson() => _$DailyOrderCountModelToJson(this);

  DailyOrderCountEntity toEntity() =>
      DailyOrderCountEntity(date: date ?? '', count: count ?? 0, orderIds: orderIds ?? []);

  factory DailyOrderCountModel.fromRawJson(String jsonString) =>
      DailyOrderCountModel.fromJson(
        json.decode(jsonString) as Map<String, dynamic>,
      );

  String toRawJson() => json.encode(toJson());
}
