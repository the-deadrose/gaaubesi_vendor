import 'package:equatable/equatable.dart';

abstract class TicketEvent extends Equatable {
  const TicketEvent();

  @override
  List<Object> get props => [];
}

class FetchTicketsEvent extends TicketEvent {
  final String page;
  final String subject;
  final String status;

  const FetchTicketsEvent({this.page = '1', required this.subject , required this.status});

  @override
  List<Object> get props => [page, subject, status];
}

class LoadMoreTicketsEvent extends TicketEvent {
  const LoadMoreTicketsEvent();

  @override
  List<Object> get props => [];
}

class RefreshTicketsEvent extends TicketEvent {
  final String subject;
  final String status;

  const RefreshTicketsEvent({required this.subject , required this.status});

  @override
  List<Object> get props => [subject, status];
}

class CreateTicketEvent extends TicketEvent {
  final String description;
  final String subject;

  const CreateTicketEvent({required this.subject, required this.description});

  @override
  List<Object> get props => [subject, description];
}

class CreateTicketReset extends TicketEvent {
  const CreateTicketReset();
}
