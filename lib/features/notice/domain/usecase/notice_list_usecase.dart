import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/notice/domain/entity/notice_list_entity.dart';
import 'package:gaaubesi_vendor/features/notice/domain/repo/notice_repository.dart';
import 'package:injectable/injectable.dart';


@lazySingleton

class NoticeListUsecase extends UseCase<NoticeListResponse, NoticeListParams> {
  final NoticeRepository _repository;
  NoticeListUsecase(this._repository);

  @override
  Future<Either<Failure, NoticeListResponse>> call(params) async {
    return await _repository.getNoticeList(
      params.page,
      params.fromDate,
      params.toDate,
    );
  }
}

class NoticeListParams {
  final String page;
  final String? fromDate;
  final String? toDate;

  NoticeListParams({required this.page, this.fromDate, this.toDate});
}
