import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/cod_transfer/domain/entity/cod_transfer_entity.dart';
import 'package:gaaubesi_vendor/features/cod_transfer/domain/repo/cod_transfer_repo.dart';
import 'package:injectable/injectable.dart';


@lazySingleton

class CodTransferListUsecase
    extends UseCase<List<CodTransferList>, CodTransferListUsecaseParams> {
  final CodTransferRepo _repository;

  CodTransferListUsecase(this._repository);

  @override
  Future<Either<Failure, List<CodTransferList>>> call(
    CodTransferListUsecaseParams params,
  ) async {
    final result = await _repository.fetchCodTransfers(page: params.page);
    return Right(result);
  }
}

class CodTransferListUsecaseParams {
  final String page;

  CodTransferListUsecaseParams({required this.page});
}
