// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_ticket_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingTicketListModel _$PendingTicketListModelFromJson(
  Map<String, dynamic> json,
) => PendingTicketListModel(
  count: (json['count'] as num).toInt(),
  next: json['next'] as String?,
  previous: json['previous'] as String?,
  results: (json['results'] as List<dynamic>)
      .map((e) => PendingTicketModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PendingTicketListModelToJson(
  PendingTicketListModel instance,
) => <String, dynamic>{
  'count': instance.count,
  'next': instance.next,
  'previous': instance.previous,
  'results': instance.results.map((e) => e.toJson()).toList(),
};

PendingTicketModel _$PendingTicketModelFromJson(Map<String, dynamic> json) =>
    PendingTicketModel(
      id: (json['id'] as num).toInt(),
      subject: json['subject'] as String,
      description: json['description'] as String,
      reply: json['reply'] as String?,
      isActive: json['isActive'] as bool,
      createdOn: json['createdOn'] as String,
      createdOnFormatted: json['createdOnFormatted'] as String,
      closedOn: json['closedOn'] as String?,
      closedOnFormatted: json['closedOnFormatted'] as String,
      closedByName: json['closedByName'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$PendingTicketModelToJson(PendingTicketModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subject': instance.subject,
      'description': instance.description,
      'reply': instance.reply,
      'isActive': instance.isActive,
      'createdOn': instance.createdOn,
      'createdOnFormatted': instance.createdOnFormatted,
      'closedOn': instance.closedOn,
      'closedOnFormatted': instance.closedOnFormatted,
      'closedByName': instance.closedByName,
      'status': instance.status,
    };
