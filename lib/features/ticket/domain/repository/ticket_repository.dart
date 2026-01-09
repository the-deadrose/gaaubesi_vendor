import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/entity/ticket_entity.dart';

abstract class TicketRepository {
  Future<Either<Failure, void>> createTicket({
    required String subject,
    required String description,
  });

  Future<Either<Failure, TicketResponseEntity>> fetchTickets({
    required String status,
    required String page,
  });
}
