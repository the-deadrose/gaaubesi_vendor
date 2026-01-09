// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketModel _$TicketModelFromJson(Map<String, dynamic> json) => TicketModel(
  id: (json['id'] as num).toInt(),
  subject: json['subject'] as String,
  description: json['description'] as String,
  reply: json['reply'] as String?,
  isActive: json['is_active'] as bool,
  createdOn: json['created_on'] as String,
  createdOnFormatted: json['created_on_formatted'] as String,
  closedOn: json['closed_on'] as String?,
  closedOnFormatted: json['closed_on_formatted'] as String?,
  closedByName: json['closed_by_name'] as String?,
  status: json['status'] as String,
);

Map<String, dynamic> _$TicketModelToJson(TicketModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subject': instance.subject,
      'description': instance.description,
      'reply': instance.reply,
      'is_active': instance.isActive,
      'created_on': instance.createdOn,
      'created_on_formatted': instance.createdOnFormatted,
      'closed_on': instance.closedOn,
      'closed_on_formatted': instance.closedOnFormatted,
      'closed_by_name': instance.closedByName,
      'status': instance.status,
    };

TicketResponseModel _$TicketResponseModelFromJson(Map<String, dynamic> json) =>
    TicketResponseModel(
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => TicketModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: (json['count'] as num).toInt(),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
    );

Map<String, dynamic> _$TicketResponseModelToJson(
  TicketResponseModel instance,
) => <String, dynamic>{
  'results': instance.results,
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
};
