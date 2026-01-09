import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/repository/ticket_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CreateTicketParams {
  final String subject;
  final String description;

  CreateTicketParams({required this.subject, required this.description});
}

class CreateTicketUseCase {
  final TicketRepository repository;

  CreateTicketUseCase({required this.repository});

  Future<Either<Failure, void>> call(CreateTicketParams params) {
    return repository.createTicket(
      subject: params.subject,
      description: params.description,
    );
  }
}
