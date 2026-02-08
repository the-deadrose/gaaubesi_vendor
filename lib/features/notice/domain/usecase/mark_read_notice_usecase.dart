import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/notice/domain/repo/notice_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class MarkReadNoticeUsecase
    implements UseCase<void, MarkReadNoticeUsecaseParams> {
  final NoticeRepository repository;

  MarkReadNoticeUsecase({required this.repository});

  @override
  Future<Either<Failure, void>> call(MarkReadNoticeUsecaseParams params) {
    return repository.markNoticeAsRead(params.noticeId);
  }
}

class MarkReadNoticeUsecaseParams {
  final String noticeId;

  MarkReadNoticeUsecaseParams({required this.noticeId});
}
