import 'package:equatable/equatable.dart';

abstract class TicketEvents extends Equatable {
  const TicketEvents();
  
  @override
  List<Object?> get props => [];
}

class CreateTicketEvent extends TicketEvents {
  final String subject;
  final String description;

  const CreateTicketEvent({required this.subject, required this.description});

  @override
  List<Object?> get props => [subject, description];
}

class FetchTicketsEvent extends TicketEvents {
  final String status;
  final String page;

  const FetchTicketsEvent({required this.status, required this.page});

  @override
  List<Object?> get props => [status, page];
}

class FetchPendingTicketsEvent extends TicketEvents {
  final String page;

  const FetchPendingTicketsEvent({required this.page});

  @override
  List<Object?> get props => [page];
}

class FetchClosedTicketsEvent extends TicketEvents {
  final String page;

  const FetchClosedTicketsEvent({required this.page});

  @override
  List<Object?> get props => [page];
}

class RefreshTicketsEvent extends TicketEvents {
  final bool isPending;

  const RefreshTicketsEvent({required this.isPending});

  @override
  List<Object?> get props => [isPending];
}

class FetchMoreTicketsEvent extends TicketEvents {
  final bool isPending;

  const FetchMoreTicketsEvent({required this.isPending});

  @override
  List<Object?> get props => [isPending];
}