import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/notice/domain/entity/notice_list_entity.dart';

abstract class NoticeRepository {
  Future<Either<Failure, NoticeListResponse>> getNoticeList(
    String page,
    String? fromDate,
    String? toDate,
  );
  Future<Either<Failure, void>> markNoticeAsRead(String noticeId);
}
