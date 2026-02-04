// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_report_analysis_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BranchReportAnalysisModel _$BranchReportAnalysisModelFromJson(
  Map<String, dynamic> json,
) => BranchReportAnalysisModel(
  destinationBranch: (json['destinationBranch'] as num?)?.toInt(),
  name: json['name'] as String?,
  total: (json['total'] as num?)?.toInt(),
  processingOrders: (json['processingOrders'] as num?)?.toInt(),
  delivered: (json['delivered'] as num?)?.toInt(),
  returned: (json['returned'] as num?)?.toInt(),
);

Map<String, dynamic> _$BranchReportAnalysisModelToJson(
  BranchReportAnalysisModel instance,
) => <String, dynamic>{
  'destinationBranch': instance.destinationBranch,
  'name': instance.name,
  'total': instance.total,
  'processingOrders': instance.processingOrders,
  'delivered': instance.delivered,
  'returned': instance.returned,
};
