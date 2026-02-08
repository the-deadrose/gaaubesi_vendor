import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/message/data/model/vendor_message_list_model.dart';
import 'package:gaaubesi_vendor/features/message/domain/entity/vendor_message_list_entity.dart';
import 'package:injectable/injectable.dart';

abstract class VendorMessageRemoteDatasource {
  Future<VendorMessageListEntity> getVendorMessageList(String page);
  Future<void> markMessageAsRead(String messageId);
}

@LazySingleton(as: VendorMessageRemoteDatasource)
class VendorMessageDatasourceImpl implements VendorMessageRemoteDatasource {
  final DioClient _dioClient;

  VendorMessageDatasourceImpl(this._dioClient);

  @override
  Future<VendorMessageListEntity> getVendorMessageList(String page) async {
    try {
      final queryParameters = <String, dynamic>{'page': page};

      final response = await _dioClient.get(
        ApiEndpoints.vendorMessages,
        queryParameters: queryParameters,
      );

      return VendorMessageListModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _dioClient.post('${ApiEndpoints.markMessageAsRead}$messageId');
    } catch (e) {
      rethrow;
    }
  }
}
    
