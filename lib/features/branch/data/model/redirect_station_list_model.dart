import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/redirect_station_list_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'redirect_station_list_model.g.dart';

@JsonSerializable()
class RedirectStationListModel extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<RedirectStationModel> results;

  const RedirectStationListModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory RedirectStationListModel.fromJson(Map<String, dynamic> json) =>
      _$RedirectStationListModelFromJson(json);

  Map<String, dynamic> toJson() => _$RedirectStationListModelToJson(this);

  @override
  List<Object?> get props => [count, next, previous, results];
}

@JsonSerializable()
class RedirectStationModel extends Equatable {
  final int id;
  @JsonKey(name: 'home_branch')
  final BranchModel homeBranch;
  @JsonKey(name: 'redirect_branches')
  final List<BranchModel> redirectBranches;

  const RedirectStationModel({
    required this.id,
    required this.homeBranch,
    required this.redirectBranches,
  });

  factory RedirectStationModel.fromJson(Map<String, dynamic> json) =>
      _$RedirectStationModelFromJson(json);

  Map<String, dynamic> toJson() => _$RedirectStationModelToJson(this);

  @override
  List<Object?> get props => [id, homeBranch, redirectBranches];
}

@JsonSerializable()
class BranchModel extends Equatable {
  final int id;
  final String name;
  final String code;
  final String district;
  final String province;

  const BranchModel({
    required this.id,
    required this.name,
    required this.code,
    required this.district,
    required this.province,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) =>
      _$BranchModelFromJson(json);

  Map<String, dynamic> toJson() => _$BranchModelToJson(this);

  @override
  List<Object?> get props => [id, name, code, district, province];
}

extension RedirectStationListModelX on RedirectStationListModel {
  RedirectStationListEntity toEntity() {
    return RedirectStationListEntity(
      count: count,
      next: next,
      previous: previous,
      results: results.map((e) => e.toEntity()).toList(),
    );
  }
}

extension RedirectStationModelX on RedirectStationModel {
  RedirectStationEntity toEntity() {
    return RedirectStationEntity(
      id: id,
      homeBranch: homeBranch.toEntity(),
      redirectBranches: redirectBranches.map((e) => e.toEntity()).toList(),
    );
  }
}

extension BranchModelX on BranchModel {
  BranchEntity toEntity() {
    return BranchEntity(
      id: id,
      name: name,
      code: code,
      district: district,
      province: province,
    );
  }
}

extension RedirectStationListEntityX on RedirectStationListEntity {
  RedirectStationListModel toModel() {
    return RedirectStationListModel(
      count: count,
      next: next,
      previous: previous,
      results: results.map((e) => e.toModel()).toList(),
    );
  }
}

extension RedirectStationEntityX on RedirectStationEntity {
  RedirectStationModel toModel() {
    return RedirectStationModel(
      id: id,
      homeBranch: homeBranch.toModel(),
      redirectBranches: redirectBranches.map((e) => e.toModel()).toList(),
    );
  }
}

extension BranchEntityX on BranchEntity {
  BranchModel toModel() {
    return BranchModel(
      id: id,
      name: name,
      code: code,
      district: district,
      province: province,
    );
  }
}