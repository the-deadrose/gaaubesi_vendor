// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pickup_order_analysis_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PickupOrderAnalysisModel _$PickupOrderAnalysisModelFromJson(
  Map<String, dynamic> json,
) => PickupOrderAnalysisModel(
  fromDate: json['from_date'] as String?,
  toDate: json['to_date'] as String?,
  totalOrders: (json['total_orders'] as num?)?.toInt(),
  dailyCounts: (json['daily_counts'] as List<dynamic>?)
      ?.map((e) => DailyOrderCountModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PickupOrderAnalysisModelToJson(
  PickupOrderAnalysisModel instance,
) => <String, dynamic>{
  'from_date': instance.fromDate,
  'to_date': instance.toDate,
  'total_orders': instance.totalOrders,
  'daily_counts': instance.dailyCounts,
};

DailyOrderCountModel _$DailyOrderCountModelFromJson(
  Map<String, dynamic> json,
) => DailyOrderCountModel(
  date: json['date'] as String?,
  count: (json['count'] as num?)?.toInt(),
  orderIds: (json['order_ids'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$DailyOrderCountModelToJson(
  DailyOrderCountModel instance,
) => <String, dynamic>{
  'date': instance.date,
  'count': instance.count,
  'order_ids': instance.orderIds,
};
