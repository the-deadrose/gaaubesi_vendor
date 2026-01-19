import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:gaaubesi_vendor/features/notice/domain/entity/notice_list_entity.dart';

part 'notice_list_model.g.dart';

@JsonSerializable(createToJson: true, explicitToJson: true)
class NoticeListResponseModel extends NoticeListResponse {
  @JsonKey(name: 'results')
  final List<NoticeModel> noticeModels;
  
  @JsonKey(name: 'count')
  final int totalCount;
  
  @JsonKey(name: 'next')
  final String? nextPage;
  
  @JsonKey(name: 'previous')
  final String? previousPage;

  const NoticeListResponseModel({
    required this.noticeModels,
    required this.totalCount,
    this.nextPage,
    this.previousPage,
  }) : super(
          notices: noticeModels,
          count: totalCount,
          next: nextPage,
          previous: previousPage,
        );

  factory NoticeListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$NoticeListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$NoticeListResponseModelToJson(this);

  factory NoticeListResponseModel.fromJsonString(String jsonString) =>
      NoticeListResponseModel.fromJson(json.decode(jsonString));

  String toJsonString() => json.encode(toJson());
}

@JsonSerializable(createToJson: true, explicitToJson: true)
class NoticeModel extends Notice {
  @JsonKey(name: 'id')
  final int noticeId;
  
  @JsonKey(name: 'title')
  final String noticeTitle;
  
  @JsonKey(name: 'content')
  final String noticeContent;
  
  @JsonKey(name: 'created_on', fromJson: _dateTimeFromJson)
  final DateTime noticeCreatedOn;
  
  @JsonKey(name: 'created_on_formatted')
  final String formattedCreatedOn;
  
  @JsonKey(name: 'created_by_name')
  final String createdBy;
  
  @JsonKey(name: 'is_read')
  final bool readStatus;
  
  @JsonKey(name: 'is_popup')
  final bool popupStatus;

  const NoticeModel({
    required this.noticeId,
    required this.noticeTitle,
    required this.noticeContent,
    required this.noticeCreatedOn,
    required this.formattedCreatedOn,
    required this.createdBy,
    required this.readStatus,
    required this.popupStatus,
  }) : super(
          id: noticeId,
          title: noticeTitle,
          content: noticeContent,
          createdOn: noticeCreatedOn,
          createdOnFormatted: formattedCreatedOn,
          createdByName: createdBy,
          isRead: readStatus,
          isPopup: popupStatus,
        );

  factory NoticeModel.fromJson(Map<String, dynamic> json) =>
      _$NoticeModelFromJson(json);

  Map<String, dynamic> toJson() => _$NoticeModelToJson(this);

  factory NoticeModel.fromJsonString(String jsonString) =>
      NoticeModel.fromJson(json.decode(jsonString));

  String toJsonString() => json.encode(toJson());

  static DateTime _dateTimeFromJson(String json) {
    try {
      return DateTime.parse(json);
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  NoticeModel copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? createdOn,
    String? createdOnFormatted,
    String? createdByName,
    bool? isRead,
    bool? isPopup,
  }) {
    return NoticeModel(
      noticeId: id ?? noticeId,
      noticeTitle: title ?? noticeTitle,
      noticeContent: content ?? noticeContent,
      noticeCreatedOn: createdOn ?? noticeCreatedOn,
      formattedCreatedOn: createdOnFormatted ?? formattedCreatedOn,
      createdBy: createdByName ?? createdBy,
      readStatus: isRead ?? readStatus,
      popupStatus: isPopup ?? popupStatus,
    );
  }
}