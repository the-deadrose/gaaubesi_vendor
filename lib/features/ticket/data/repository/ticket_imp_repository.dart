import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/ticket/data/datasource/tickect_datasorce.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/entity/pending_ticket_list_entity.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/repository/ticket_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: TicketRepository)
class TicketImpRepository implements TicketRepository {
  final RemoteTicketDataSource remoteTicketDataSource;

  TicketImpRepository({required this.remoteTicketDataSource});

  @override
  Future<Either<Failure, void>> createTicket({
    required String subject,
    required String description,
  }) async {
    try {
      await remoteTicketDataSource.createTicket(
        subject: subject,
        description: description,
      );
      return Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PendingTicketListEntity>> fetchTickets({
    required String subject,
    required String page,
    required String status,
  }) async {
    try {
      final response = await remoteTicketDataSource.fetchTickets(
        subject: subject,
        page: page,
        status: status,
      );
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
