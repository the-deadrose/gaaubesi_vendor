import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/customer/domain/entity/customer_detail_entity.dart';
import 'package:gaaubesi_vendor/features/customer/domain/repository/customer_repo.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CustomerDetailUsecase
    extends UseCase<CustomerDetailEntity, CustomerDetailParams> {
  final CustomerRepo _repository;

  CustomerDetailUsecase(this._repository);

  @override
  Future<Either<Failure, CustomerDetailEntity>> call(params) async {
    return await _repository.getCustomerDetail(params.customerId);
  }
}

class CustomerDetailParams {
  final String customerId;

  CustomerDetailParams({required this.customerId});
}
