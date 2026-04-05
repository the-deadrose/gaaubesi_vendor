import 'package:gaaubesi_vendor/features/branch/domain/entity/branch_list_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'branch_list_model.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class BranchListModel {
  @JsonKey(name: 'id', defaultValue: 0)
  final int id;
  
  @JsonKey(name: 'code', defaultValue: '')
  final String code;
  
  @JsonKey(name: 'name', defaultValue: '')
  final String name;

  const BranchListModel({
    required this.id,
    required this.code,
    required this.name,
  });

  factory BranchListModel.fromJson(Map<String, dynamic> json) =>
      _$BranchListModelFromJson(json);

  Map<String, dynamic> toJson() => _$BranchListModelToJson(this);

  BranchListEntity toEntity() => BranchListEntity(
        value: id.toString(), // Use ID as value for backend
        label: name, // Show only name in dropdown
        code: code, // Branch code for matching
      );

  factory BranchListModel.fromEntity(BranchListEntity entity) =>
      BranchListModel(
        id: int.tryParse(entity.value) ?? 0,
        code: entity.code,
        name: entity.label,
      );
}
