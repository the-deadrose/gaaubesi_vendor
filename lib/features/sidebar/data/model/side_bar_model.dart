import 'package:gaaubesi_vendor/features/sidebar/domain/entity/sidebar_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'side_bar_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SideBarModel extends SideBarEntity {
  @override
  @JsonKey(name: 'sub_items')
  final List<SideBarModel>? subItems;

  const SideBarModel({
    required String name,
    String? permission,
    @JsonKey(name: 'has_access') required bool hasAccess,
    @JsonKey(name: 'sub_items') this.subItems,
  }) : super(
         name: name,
         permission: permission,
         hasAccess: hasAccess,
         subItems: subItems,
       );

  factory SideBarModel.fromJson(Map<String, dynamic> json) =>
      _$SideBarModelFromJson(json);

  Map<String, dynamic> toJson() => _$SideBarModelToJson(this);
}
