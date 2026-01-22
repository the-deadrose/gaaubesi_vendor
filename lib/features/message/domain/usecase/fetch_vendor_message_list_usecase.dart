import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/message/domain/entity/vendor_message_list_entity.dart';
import 'package:gaaubesi_vendor/features/message/domain/repo/vendor_message_repo.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FetchVendorMessageListUsecase
    extends UseCase<VendorMessageListEntity, FetchVendorMessageListParams> {
  final VendorMessageRepository repository;
  FetchVendorMessageListUsecase({required this.repository});

  @override
  Future<Either<Failure, VendorMessageListEntity>> call(
    FetchVendorMessageListParams params,
  ) {
    return repository.sendVendorMessage(params.page);
  }
}

class FetchVendorMessageListParams {
  final String page;

  FetchVendorMessageListParams({required this.page});
}
