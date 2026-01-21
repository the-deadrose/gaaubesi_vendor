import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/payment_request/data/model/frequently_used_and_payment_method_model.dart';
import 'package:gaaubesi_vendor/features/payment_request/data/model/payment_request_list_model.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/entity/frequently_used_and_payment_method_entity.dart';
import 'package:gaaubesi_vendor/features/payment_request/domain/entity/payment_request_list_entity.dart';
import 'package:injectable/injectable.dart';

abstract class PaymentRequestRemoteDatasource {
  Future<FrequentlyUsedAndPaymentMethodList> fetchFrequentlyUsedMethodDetails();
  Future<void> createPaymentRequest({
    required String paymentMethod,
    required String discribtion,
    required String bankName,
    required String accountNumber,
    required String accountName,
    required String phoneNumber,
  });

  Future<PaymentRequestListEntity> fetchPaymentRequests({
    required String page,
    required String status,
    required String paymentMethod,
    required String bankName,
  });
}

@LazySingleton(as: PaymentRequestRemoteDatasource)
class PaymentRequestDatasourceImpl implements PaymentRequestRemoteDatasource {
  final DioClient _dioClient;
  PaymentRequestDatasourceImpl(this._dioClient);

  @override
  Future<FrequentlyUsedAndPaymentMethodList>
  fetchFrequentlyUsedMethodDetails() async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.frequentlyUsedPaymentMethods,
      );
      final data = response.data;
      if (data != null) {
        final frequentlyUsedAndPaymentMethodModel =
            FrequentlyUsedAndPaymentMethodListModel.fromJson(
              data as Map<String, dynamic>,
            );
        return frequentlyUsedAndPaymentMethodModel.toEntity();
      } else {
        throw Exception('No response data found');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createPaymentRequest({
    required String paymentMethod,
    required String discribtion,
    required String bankName,
    required String accountNumber,
    required String accountName,
    required String phoneNumber,
  }) async {
    try {
      final body = {
        'payment_method': paymentMethod,
        'description': discribtion,
        'payment_bank_name': bankName,
        'payment_account_number': accountNumber,
        'payment_account_name': accountName,
        'payment_phone_number': phoneNumber,
      };
      await _dioClient.post(
        ApiEndpoints.frequentlyUsedPaymentMethods,
        data: body,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PaymentRequestListEntity> fetchPaymentRequests({
    required String page,
    required String status,
    required String paymentMethod,
    required String bankName,
  }) async {
    // try {
      final queryParameters = <String, dynamic>{
        'page': page,
      };
      
      // Only add filter parameters if they're not 'all'
      if (status != 'all') {
        queryParameters['status'] = status;
      }
      if (paymentMethod != 'all') {
        queryParameters['payment_method'] = paymentMethod;
      }
      if (bankName != 'all') {
        queryParameters['payment_bank_name'] = bankName;
      }
      
      final response = await _dioClient.get(
        ApiEndpoints.paymentRequest,
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (data != null) {
        final paymentRequestListModel = PaymentRequestListModel.fromJson(
          data as Map<String, dynamic>,
        );
        return paymentRequestListModel;
      } else {
        throw Exception('No response data found');
      }
    // } catch (e) {
    //   rethrow;  
    // }
  }
}
