import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/message/domain/repo/vendor_message_repo.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class MarkAsReadMessageUsecase
    implements UseCase<void, MarkAsReadMessageUsecaseParams> {
  final VendorMessageRepository repository;

  MarkAsReadMessageUsecase({required this.repository});

  @override
  Future<Either<Failure, void>> call(MarkAsReadMessageUsecaseParams params) {
    return repository.markMessageAsRead(params.messageId);
  }
}

class MarkAsReadMessageUsecaseParams {
  final String messageId;

  MarkAsReadMessageUsecaseParams({required this.messageId});
}
