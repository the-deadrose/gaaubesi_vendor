import 'package:flutter/widgets.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/entity/pending_ticket_list_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pending_ticket_list_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PendingTicketListModel extends PendingTicketListEntity {
  @override
  final List<PendingTicketModel> results;

  const PendingTicketListModel({
    required super.count,
    super.next,
    super.previous,
    required this.results,
  }) : super(results: results);

  factory PendingTicketListModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$PendingTicketListModelFromJson(json);
    } catch (e) {
      // Log the error and provide a default/empty response
      debugPrint('Error parsing PendingTicketListModel: $e');
      debugPrint('JSON received: $json');

      // Return empty model instead of throwing to prevent app crash
      return PendingTicketListModel(
        count: json['count'] as int? ?? 0,
        next: json['next'] as String?,
        previous: json['previous'] as String?,
        results:
            (json['results'] as List<dynamic>?)?.map((e) {
              try {
                return PendingTicketModel.fromJson(e as Map<String, dynamic>);
              } catch (innerError) {
                debugPrint('Error parsing individual ticket: $innerError');
                return PendingTicketModel.empty();
              }
            }).toList() ??
            [],
      );
    }
  }

  Map<String, dynamic> toJson() => _$PendingTicketListModelToJson(this);
}

@JsonSerializable()
class PendingTicketModel extends PendingTicketEntity {
  const PendingTicketModel({
    required super.id,
    required super.subject,
    required super.description,
    super.reply,
    required super.isActive,
    required super.createdOn,
    required super.createdOnFormatted,
    super.closedOn,
    required super.closedOnFormatted,
    required super.closedByName,
    required super.status,
  });

  // Add a factory constructor for empty/default values
  factory PendingTicketModel.empty() {
    return PendingTicketModel(
      id: -1,
      subject: '',
      description: '',
      reply: null,
      isActive: false,
      createdOn: '',
      createdOnFormatted: '',
      closedOn: null,
      closedOnFormatted: '',
      closedByName: '',
      status: 'pending',
    );
  }

  factory PendingTicketModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$PendingTicketModelFromJson(json);
    } catch (e) {
      // Log the error and parse with defaults
      debugPrint('Error parsing PendingTicketModel: $e');
      debugPrint('JSON received: $json');

      // Provide default values for missing fields
      return PendingTicketModel(
        id: json['id'] as int? ?? -1,
        subject: json['subject'] as String? ?? 'No Subject',
        description: json['description'] as String? ?? 'No Description',
        reply: json['reply'] as String?,
        isActive: json['is_active'] as bool? ?? false,
        createdOn: json['created_on'] as String? ?? '',
        createdOnFormatted: json['created_on_formatted'] as String? ?? '',
        closedOn: json['closed_on'] as String?,
        closedOnFormatted: json['closed_on_formatted'] as String? ?? '',
        closedByName: json['closed_by_name'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
      );
    }
  }

  Map<String, dynamic> toJson() => _$PendingTicketModelToJson(this);
}
