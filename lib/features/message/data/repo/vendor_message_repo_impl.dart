import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/message/data/datasource/vendor_message_datasource.dart';
import 'package:gaaubesi_vendor/features/message/domain/entity/vendor_message_list_entity.dart';
import 'package:gaaubesi_vendor/features/message/domain/repo/vendor_message_repo.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: VendorMessageRepository)
class VendorMessageRepoImpl implements VendorMessageRepository {
  final VendorMessageRemoteDatasource remoteDatasource;

  VendorMessageRepoImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, VendorMessageListEntity>> sendVendorMessage(
    String page,
  ) async {
    try {
      final result = await remoteDatasource.getVendorMessageList(page);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch vendor messages'));
    }
  }

  @override
  Future<Either<Failure, void>> markMessageAsRead(String messageId) async {
    try {
      final result = await remoteDatasource.markMessageAsRead(messageId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Failed to mark message as read'));
    }
  }
}
