import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/ticket/data/model/pending_ticket_list_model.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/entity/pending_ticket_list_entity.dart';
import 'package:injectable/injectable.dart';

abstract class RemoteTicketDataSource {
  Future<void> createTicket({
    required String subject,
    required String description,
  });

  Future<PendingTicketListEntity> fetchTickets({
    required String subject,
    required String page,
    required String status,
  });

  Future<PendingTicketListEntity> fetchTicketsByStatus({
    required String page,
    required String status,
  });

  Future<PendingTicketListEntity> fetchTicketsBySubject({
    required String page,
    required String subject,
  });
}

@LazySingleton(as: RemoteTicketDataSource)
class TickectDatasorceImp implements RemoteTicketDataSource {
  final DioClient _dioClient;

  TickectDatasorceImp(this._dioClient);

  @override
  Future<void> createTicket({
    required String subject,
    required String description,
  }) async {
    try {
      final data = {'subject': subject, 'description': description};
      await _dioClient.post(ApiEndpoints.createTicket, data: data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PendingTicketListEntity> fetchTickets({
    required String subject,
    required String page,
    required String status,
  }) async {
    if (subject.isEmpty) {
      return await fetchTicketsByStatus(page: page, status: status);
    } else {
      return await fetchTicketsBySubject(page: page, subject: subject);
    }
  }

  @override
  Future<PendingTicketListEntity> fetchTicketsByStatus({
    required String page,
    required String status,
  }) async {
    try {
      String url = '${ApiEndpoints.ticketList}$status/';
      final queryParameters = {'page': page};

      final response = await _dioClient.get(
        url,
        queryParameters: queryParameters,
      );

      return PendingTicketListModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PendingTicketListEntity> fetchTicketsBySubject({
    required String page,
    required String subject,
  }) async {
    try {
      final url = ApiEndpoints.ticketList;
      final queryParameters = {'page': page, 'subject': subject};

      final response = await _dioClient.get(
        url,
        queryParameters: queryParameters,
      );

      return PendingTicketListModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      rethrow;
    }
  }
}

