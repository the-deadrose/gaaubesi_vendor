import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/payments/data/model/payment_request_list_model.dart';
import 'package:gaaubesi_vendor/features/payments/domain/entity/payment_request_list_entity.dart';
import 'package:injectable/injectable.dart';

abstract class PayementRequestRemoteDatasource {
  Future<PaymentRequestList> getPaymentRequestList();
}

@LazySingleton(as: PayementRequestRemoteDatasource)
class PayementRequestRemoteDatasourceImpl
    implements PayementRequestRemoteDatasource {
  final DioClient _dioClient;

  PayementRequestRemoteDatasourceImpl(this._dioClient);

  @override
  Future<PaymentRequestList> getPaymentRequestList() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.paymentRequestList);

      return PaymentRequestListModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
