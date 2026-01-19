import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/cod_transfer/domain/entity/cod_transfer_entity.dart';
import 'package:gaaubesi_vendor/features/cod_transfer/data/model/cod_transfer_model.dart';
import 'package:injectable/injectable.dart';

abstract class CodTransferRemoteDataource{
Future<List<CodTransferList>> fetchCodTransferList({
  required int page,
});
}

@LazySingleton(as: CodTransferRemoteDataource)

class CodTransferDatasourceImpl implements CodTransferRemoteDataource {
  final DioClient _dioClient;

  CodTransferDatasourceImpl(this._dioClient);

  @override
  Future<List<CodTransferList>> fetchCodTransferList({
    required int page,
  }) async {
    try {
      final queryParameters = {
        'page': page,
      };

      final response = await _dioClient.get(
        ApiEndpoints.codTransfer,
        queryParameters: queryParameters,
      );

      final paginatedResponse = CodTransferPaginatedResponse.fromJson(response.data);
      return paginatedResponse.toEntityList();
    } catch (e) {
      rethrow;
    }
  }
}