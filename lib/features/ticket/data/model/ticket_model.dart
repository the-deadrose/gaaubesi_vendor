import 'package:json_annotation/json_annotation.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/entity/ticket_entity.dart';

part 'ticket_model.g.dart';

@JsonSerializable()
class TicketModel {
  @JsonKey(name: 'id')
  final int id;
  
  @JsonKey(name: 'subject')
  final String subject;
  
  @JsonKey(name: 'description')
  final String description;
  
  @JsonKey(name: 'reply')
  final String? reply;
  
  @JsonKey(name: 'is_active')
  final bool isActive;
  
  @JsonKey(name: 'created_on')
  final String createdOn;
  
  @JsonKey(name: 'created_on_formatted')
  final String createdOnFormatted;
  
  @JsonKey(name: 'closed_on')
  final String? closedOn;
  
  @JsonKey(name: 'closed_on_formatted')
  final String? closedOnFormatted;
  
  @JsonKey(name: 'closed_by_name')
  final String? closedByName;
  
  @JsonKey(name: 'status')
  final String status;

  const TicketModel({
    required this.id,
    required this.subject,
    required this.description,
    this.reply,
    required this.isActive,
    required this.createdOn,
    required this.createdOnFormatted,
    this.closedOn,
    this.closedOnFormatted,
    this.closedByName,
    required this.status,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) =>
      _$TicketModelFromJson(json);

  Map<String, dynamic> toJson() => _$TicketModelToJson(this);

  TicketEntity toEntity() {
    return TicketEntity(
      id: id,
      subject: subject,
      description: description,
      reply: reply,
      isActive: isActive,
      createdOn: createdOn,
      createdOnFormatted: createdOnFormatted,
      closedOn: closedOn,
      closedOnFormatted: closedOnFormatted,
      closedByName: closedByName,
      status: status,
    );
  }
}

@JsonSerializable()
class TicketResponseModel {
  @JsonKey(name: 'results')
  final List<TicketModel>? results;
  
  @JsonKey(name: 'count')
  final int count;
  
  @JsonKey(name: 'next')
  final String? next;
  
  @JsonKey(name: 'previous')
  final String? previous;

  const TicketResponseModel({
    this.results,
    required this.count,
    this.next,
    this.previous,
  });

  factory TicketResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TicketResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$TicketResponseModelToJson(this);

  TicketResponseEntity toEntity() {
    return TicketResponseEntity(
      results: results?.map((model) => model.toEntity()).toList(),
      count: count,
      next: next,
      previous: previous,
    );
  }
}