import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/ticket/data/datasource/tickect_datasorce.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/entity/ticket_entity.dart';
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
  Future<Either<Failure, TicketResponseEntity>> fetchTickets({
    required String status,
    required String page,
  }) async {
    try {
      final response = await remoteTicketDataSource.fetchTickets(
        status: status,
        page: page,
      );
      return Right(response.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
