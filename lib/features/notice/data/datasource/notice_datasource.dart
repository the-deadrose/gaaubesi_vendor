import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:gaaubesi_vendor/configure/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/notice/data/model/notice_list_model.dart';
import 'package:gaaubesi_vendor/features/notice/domain/entity/notice_list_entity.dart';
import 'package:injectable/injectable.dart';

abstract class NoticeRemoteDatasource {
  Future<NoticeListResponse> getNoticeList(
    String page,
    String? startDate,
    String? endDate,
  );

  Future<void> markNoticeAsRead(String noticeId);
}

@LazySingleton(as: NoticeRemoteDatasource)
class NoticeRemoteDatasourceImpl implements NoticeRemoteDatasource {
  final DioClient _dioClient;

  NoticeRemoteDatasourceImpl(this._dioClient);

  @override
  Future<NoticeListResponse> getNoticeList(
    String page,
    String? startDate,
    String? endDate,
  ) async {
    try {
      final queryParameters = <String, dynamic>{'page': page};
      if (startDate != null && startDate.isNotEmpty) {
        queryParameters['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParameters['end_date'] = endDate;
      }

      final response = await _dioClient.get(
        ApiEndpoints.noticeList,
        queryParameters: queryParameters,
      );

      debugPrint('[NoticeRemoteDatasource] notice list response: ${response.data}');
      debugPrint(
        '[NoticeRemoteDatasource] notice list statusCode: ${response.statusCode}',
      );

      return NoticeListResponseModel.fromJson(response.data);
    } catch (e) {
      final statusCode = e is DioException
          ? e.response?.statusCode
          : null;
      debugPrint(
        '[NoticeRemoteDatasource] notice list errorType=${e.runtimeType} '
        'statusCode=$statusCode error=$e',
      );
      rethrow;
    }
  }

  @override
  Future<void> markNoticeAsRead(String noticeId) async {
    try {
      final response =
          await _dioClient.post('${ApiEndpoints.markNoticeAsRead}$noticeId');
      debugPrint('[NoticeRemoteDatasource] mark as read response: ${response.data}');
      debugPrint(
        '[NoticeRemoteDatasource] mark as read statusCode: ${response.statusCode}',
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to mark notice as read');
      }
    } catch (e) {
      final statusCode = e is DioException
          ? e.response?.statusCode
          : null;
      debugPrint(
        '[NoticeRemoteDatasource] mark as read errorType=${e.runtimeType} '
        'statusCode=$statusCode error=$e',
      );
      rethrow;
    }
  }
}
