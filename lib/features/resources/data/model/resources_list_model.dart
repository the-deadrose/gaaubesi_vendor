import 'package:gaaubesi_vendor/features/resources/domain/entity/resources_list_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'resources_list_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ResourcesListModel extends ResourcesListEntity {
  @override
  @JsonKey(defaultValue: 0)
  final int count;

  @override
  final String? next;

  @override
  final String? previous;

  @override
  @JsonKey(defaultValue: [])
  final List<ResourceItemModel> results;

  const ResourcesListModel({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  }) : super(
          count: count,
          next: next,
          previous: previous,
          results: results,
        );

  factory ResourcesListModel.fromJson(Map<String, dynamic> json) =>
      _$ResourcesListModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResourcesListModelToJson(this);
}

@JsonSerializable()
class ResourceItemModel extends ResourceItemEntity {
  @override
  @JsonKey(defaultValue: '')
  final String title;

  @override
  @JsonKey(defaultValue: '')
  final String description;

  @override
  @JsonKey(defaultValue: '')
  final String view;

  const ResourceItemModel({
    required this.title,
    required this.description,
    required this.view,
  }) : super(
          title: title,
          description: description,
          view: view,
        );

  factory ResourceItemModel.fromJson(Map<String, dynamic> json) =>
      _$ResourceItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceItemModelToJson(this);
}
