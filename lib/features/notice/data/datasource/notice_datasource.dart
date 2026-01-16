import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/notice/data/model/notice_list_model.dart';
import 'package:gaaubesi_vendor/features/notice/domain/entity/notice_list_entity.dart';
import 'package:injectable/injectable.dart';

abstract class NoticeRemoteDatasource {
  Future<NoticeListResponse> getNoticeList(
    String page,
    String startDate,
    String endDate,
  );
}

@LazySingleton(as: NoticeRemoteDatasource)
class NoticeRemoteDatasourceImpl implements NoticeRemoteDatasource {
  final DioClient _dioClient;

  NoticeRemoteDatasourceImpl(this._dioClient);

  @override
  Future<NoticeListResponse> getNoticeList(
    String page,
    String startDate,
    String endDate,
  ) async {
    try {
      final queryParameters = <String, dynamic>{'page': page};
      queryParameters['start_date'] = startDate;
      queryParameters['end_date'] = endDate;

      final response = await _dioClient.get(
        ApiEndpoints.noticeList,
        queryParameters: queryParameters,
      );

      return NoticeListResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
