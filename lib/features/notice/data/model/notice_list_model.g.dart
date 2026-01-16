// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoticeListResponseModel _$NoticeListResponseModelFromJson(
  Map<String, dynamic> json,
) => NoticeListResponseModel(
  noticeModels: (json['results'] as List<dynamic>)
      .map((e) => NoticeModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['count'] as num).toInt(),
  nextPage: json['next'] as String?,
  previousPage: json['previous'] as String?,
);

Map<String, dynamic> _$NoticeListResponseModelToJson(
  NoticeListResponseModel instance,
) => <String, dynamic>{
  'results': instance.noticeModels.map((e) => e.toJson()).toList(),
  'count': instance.totalCount,
  'next': instance.nextPage,
  'previous': instance.previousPage,
};

NoticeModel _$NoticeModelFromJson(Map<String, dynamic> json) => NoticeModel(
  noticeId: (json['id'] as num).toInt(),
  noticeTitle: json['title'] as String,
  noticeContent: json['content'] as String,
  noticeCreatedOn: NoticeModel._dateTimeFromJson(json['created_on'] as String),
  formattedCreatedOn: json['created_on_formatted'] as String,
  createdBy: json['created_by_name'] as String,
  readStatus: json['is_read'] as bool,
  popupStatus: json['is_popup'] as bool,
);

Map<String, dynamic> _$NoticeModelToJson(NoticeModel instance) =>
    <String, dynamic>{
      'id': instance.noticeId,
      'title': instance.noticeTitle,
      'content': instance.noticeContent,
      'created_on': instance.noticeCreatedOn.toIso8601String(),
      'created_on_formatted': instance.formattedCreatedOn,
      'created_by_name': instance.createdBy,
      'is_read': instance.readStatus,
      'is_popup': instance.popupStatus,
    };
