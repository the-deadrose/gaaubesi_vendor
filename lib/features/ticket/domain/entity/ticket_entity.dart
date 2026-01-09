import 'package:equatable/equatable.dart';

class TicketEntity extends Equatable {
  final int id;
  final String subject;
  final String description;
  final String? reply;
  final bool isActive;
  final String createdOn;
  final String createdOnFormatted;
  final String? closedOn;
  final String? closedOnFormatted;
  final String? closedByName;
  final String status;

  const TicketEntity({
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

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isClosed => status.toLowerCase() == 'closed';

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

class TicketResponseEntity extends Equatable {
  final List<TicketEntity>? results;
  final int count;
  final String? next;
  final String? previous;

  const TicketResponseEntity({
    this.results,
    required this.count,
    this.next,
    this.previous,
  });

  @override
  List<Object?> get props => [results, count, next, previous];
}