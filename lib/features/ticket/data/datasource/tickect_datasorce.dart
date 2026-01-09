import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/ticket/data/model/ticket_model.dart';
import 'package:injectable/injectable.dart';

abstract class RemoteTicketDataSource {
  Future<void> createTicket({
    required String subject,
    required String description,
  });

  Future<TicketResponseModel> fetchTickets({
    required String status,
    required String page,
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
  Future<TicketResponseModel> fetchTickets({
    required String status,
    required String page,
  }) async {
    try {
      final queryParameters = {'status': status, 'page': page};
      final response = await _dioClient.get(
        ApiEndpoints.ticketList,
        queryParameters: queryParameters,
      );
      
      return TicketResponseModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
