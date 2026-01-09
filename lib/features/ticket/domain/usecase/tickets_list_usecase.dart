
import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/entity/ticket_entity.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/repository/ticket_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class TicketsListParams {
  final String subject;
  final String description;

  const TicketsListParams({required this.subject, required this.description});
}

class TicketsListUseCase {
  final TicketRepository repository;

  TicketsListUseCase({required this.repository});

  Future<Either<Failure, TicketResponseEntity>> call(TicketsListParams params) {
    return repository.fetchTickets(
      status: params.subject,
      page: params.description,
    );
  }
}