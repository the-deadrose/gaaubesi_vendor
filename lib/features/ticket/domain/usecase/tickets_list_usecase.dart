
import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/entity/pending_ticket_list_entity.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/repository/ticket_repository.dart';
import 'package:injectable/injectable.dart';

class TicketsListParams {
  final String page;
  final String subject;
  final String status;

  const TicketsListParams({required this.page, required this.subject , required this.status});
}
@lazySingleton
class TicketsListUseCase {
  final TicketRepository repository;

  TicketsListUseCase({required this.repository});

  Future<Either<Failure, PendingTicketListEntity>> call(TicketsListParams params) {
    return repository.fetchTickets(
      subject: params.subject,
      page: params.page,
      status: params.status,
    );
  }
}