import 'package:gaaubesi_vendor/features/analysis/domain/entity/branch_report_analysis_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'branch_report_analysis_model.g.dart';

@JsonSerializable(disallowUnrecognizedKeys: false)
class BranchReportAnalysisModel extends BranchReportAnalysisEntity {
  const BranchReportAnalysisModel({
    int? destinationBranch,
    String? name,
    int? total,
    int? processingOrders,
    int? delivered,
    int? returned,
  }) : super(
    destinationBranch: destinationBranch ?? 0,
    name: name ?? '',
    total: total ?? 0,
    processingOrders: processingOrders ?? 0,
    delivered: delivered ?? 0,
    returned: returned ?? 0,
  );

  factory BranchReportAnalysisModel.fromJson(Map<String, dynamic> json) =>
      _$BranchReportAnalysisModelFromJson(json);

  Map<String, dynamic> toJson() => _$BranchReportAnalysisModelToJson(this);

  factory BranchReportAnalysisModel.fromEntity(
    BranchReportAnalysisEntity entity,
  ) {
    return BranchReportAnalysisModel(
      destinationBranch: entity.destinationBranch,
      name: entity.name,
      total: entity.total,
      processingOrders: entity.processingOrders,
      delivered: entity.delivered,
      returned: entity.returned,
    );
  }

  BranchReportAnalysisEntity toEntity() => this;

  @override
  BranchReportAnalysisModel copyWith({
    int? destinationBranch,
    String? name,
    int? total,
    int? processingOrders,
    int? delivered,
    int? returned,
  }) {
    return BranchReportAnalysisModel(
      destinationBranch: destinationBranch ?? this.destinationBranch,
      name: name ?? this.name,
      total: total ?? this.total,
      processingOrders: processingOrders ?? this.processingOrders,
      delivered: delivered ?? this.delivered,
      returned: returned ?? this.returned,
    );
  }
}
