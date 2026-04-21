import 'package:gaaubesi_vendor/features/contacts/domain/entity/sub_branch_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sub_branches_model.g.dart';

@JsonSerializable()
class SubBranchesModel extends SubBranchesEntity {
  const SubBranchesModel({
    String? name,
    String? district,
    @JsonKey(name: 'phone_numbers', defaultValue: {})
    Map<String, String>? phoneNumbers,
    @JsonKey(name: 'base_charge')
    double? baseCharge,
    @JsonKey(name: 'area_covered', defaultValue: '')
    String? areaCovered,
    @JsonKey(name: 'arrival_time', defaultValue: '')
    String? arrivalTime,
  }) : super(
          name: name ?? '',
          district: district ?? '',
          phoneNumbers: phoneNumbers ?? const {},
          baseCharge: baseCharge ?? 0.0,
          areaCovered: areaCovered ?? '',
          arrivalTime: arrivalTime ?? '',
        );

  factory SubBranchesModel.fromJson(Map<String, dynamic> json) =>
      _$SubBranchesModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubBranchesModelToJson(this);
}

@JsonSerializable()
class SubBranchesResponseModel extends SubBranchesResponseEntity {
  final int count;

  final String? next;

  final String? previous;

  final List<SubBranchesModel> results;

  const SubBranchesResponseModel({
    required this.count,
    this.next,
    this.previous,
    required List<SubBranchesModel>? results,
  }) : results = results ?? const [],
       super(
          count: count,
          next: next ?? '',
          previous: previous ?? '',
          results: results ?? const [],
        );

  factory SubBranchesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SubBranchesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubBranchesResponseModelToJson(this);

  SubBranchesResponseEntity toEntity() {
    return SubBranchesResponseEntity(
      count: count,
      next: next,
      previous: previous,
      results: results.map((model) => model as SubBranchesEntity).toList(),
    );
  }
}