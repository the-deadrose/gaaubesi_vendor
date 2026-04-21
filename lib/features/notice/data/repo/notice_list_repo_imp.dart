import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/data/failure_mapper.dart';
import 'package:gaaubesi_vendor/features/notice/data/datasource/notice_datasource.dart';
import 'package:gaaubesi_vendor/features/notice/domain/entity/notice_list_entity.dart';
import 'package:gaaubesi_vendor/features/notice/domain/repo/notice_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: NoticeRepository)
class NoticeListRepoImp implements NoticeRepository {
  final NoticeRemoteDatasource remoteDatasource;

  NoticeListRepoImp({required this.remoteDatasource});

  @override
  Future<Either<Failure, NoticeListResponse>> getNoticeList(
    String page,
    String? startDate,
    String? endDate,
  ) async {
    try {
      debugPrint(
        '[NoticeListRepoImp] getNoticeList page=$page startDate=$startDate endDate=$endDate',
      );
      final result = await remoteDatasource.getNoticeList(
        page,
        startDate,
        endDate,
      );
      debugPrint(
        '[NoticeListRepoImp] getNoticeList success count=${result.count} '
        'next=${result.next} previous=${result.previous}',
      );
      return Right(result);
    } catch (e) {
      debugPrint('[NoticeListRepoImp] getNoticeList error: $e');
      return Left(toFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> markNoticeAsRead(String noticeId) async {
    try {
      debugPrint('[NoticeListRepoImp] markNoticeAsRead noticeId=$noticeId');
      final result = await remoteDatasource.markNoticeAsRead(noticeId);
      debugPrint('[NoticeListRepoImp] markNoticeAsRead success');
      return Right(result);
    } catch (e) {
      debugPrint('[NoticeListRepoImp] markNoticeAsRead error: $e');
      return Left(toFailure(e));
    }
  }
}
