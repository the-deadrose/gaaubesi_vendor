import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
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
      final result = await remoteDatasource.getNoticeList(
        page,
        startDate.toString(),
        endDate.toString(),
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch notice list'));
    }
  }
}
