import 'package:equatable/equatable.dart';

class PendingTicketListEntity extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<PendingTicketEntity> results;

  const PendingTicketListEntity({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  @override
  List<Object?> get props => [count, next, previous, results];
}

class PendingTicketEntity extends Equatable {
  final int id;
  final String subject;
  final String description;
  final String? reply;
  final bool isActive;
  final String createdOn;
  final String createdOnFormatted;
  final String? closedOn;
  final String closedOnFormatted;
  final String closedByName;
  final String status;

  const PendingTicketEntity({
    required this.id,
    required this.subject,
    required this.description,
    this.reply,
    required this.isActive,
    required this.createdOn,
    required this.createdOnFormatted,
    this.closedOn,
    required this.closedOnFormatted,
    required this.closedByName,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        subject,
        description,
        reply,
        isActive,
        createdOn,
        createdOnFormatted,
        closedOn,
        closedOnFormatted,
        closedByName,
        status,
      ];
}
