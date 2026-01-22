// ignore_for_file: invalid_annotation_target

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entity/vendor_message_list_entity.dart';

part 'vendor_message_list_model.g.dart';

@JsonSerializable(explicitToJson: true, createToJson: true)
class VendorMessageListModel extends VendorMessageListEntity {
  @override
  @JsonKey(name: 'results', required: true)
  final List<VendorMessageModel> results;

  const VendorMessageListModel({
    @JsonKey(name: 'count', required: true) required super.count,
    @JsonKey(name: 'next') super.next,
    @JsonKey(name: 'previous') super.previous,
    required this.results,
  }) : super(results: results);

  factory VendorMessageListModel.fromJson(Map<String, dynamic> json) =>
      _$VendorMessageListModelFromJson(json);

  Map<String, dynamic> toJson() => _$VendorMessageListModelToJson(this);
}

@JsonSerializable(explicitToJson: true, createToJson: true)
class VendorMessageModel extends VendorMessageEntity {
  const VendorMessageModel({
    @JsonKey(name: 'id', required: true) required super.id,
    @JsonKey(name: 'message', required: true) required super.message,
    @JsonKey(name: 'created_on', required: true, fromJson: _dateTimeFromJson)
    required super.createdOn,
    @JsonKey(name: 'created_on_formatted', required: true)
    required super.createdOnFormatted,
    @JsonKey(name: 'created_by_name', required: true)
    required super.createdByName,
    @JsonKey(name: 'is_read', required: true) required super.isRead,
  });

  factory VendorMessageModel.fromJson(Map<String, dynamic> json) =>
      _$VendorMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$VendorMessageModelToJson(this);

  static DateTime _dateTimeFromJson(dynamic value) {
    if (value is String) {
      return DateTime.parse(value);
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    throw ArgumentError('Invalid date format');
  }
}
