import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/calculate_charge/data/model/calculate_delivery_charge_model.dart';
import 'package:gaaubesi_vendor/features/calculate_charge/domain/entity/calculate_deliver_charge_entity.dart';
import 'package:injectable/injectable.dart';

abstract class CalculateDeliveryChargeRemoteDatasource {
  Future<CalculateDeliveryCharge> calculateDeliveryCharge({
    required String sourceBranchId,
    required String destinationBranchId,
    required String weight,
  });
}

@LazySingleton(as: CalculateDeliveryChargeRemoteDatasource)
class CalculateDeliveryChargeDatasourceImpl
    implements CalculateDeliveryChargeRemoteDatasource {
  final DioClient _dioClient;

  CalculateDeliveryChargeDatasourceImpl(this._dioClient);

  @override
  Future<CalculateDeliveryCharge> calculateDeliveryCharge({
    required String sourceBranchId,
    required String destinationBranchId,
    required String weight,
  }) async {
    try {
      final queryParameters = {
        'source_branch': sourceBranchId,
        'destination_branch': destinationBranchId,
        'weight': weight,
      };
      final response = await _dioClient.get(
        ApiEndpoints.calculateDeliveryCharge,
        queryParameters: queryParameters,
      );
      return CalculateDeliveryChargeModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
