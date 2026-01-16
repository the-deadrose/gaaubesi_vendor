import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:gaaubesi_vendor/features/customer/domain/entity/customer_list_entity.dart';
import 'package:gaaubesi_vendor/features/customer/domain/repository/customer_repo.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CustomerListUseCase extends UseCase<CustomerListResponse, CustomerUsecaseParams> {
  final CustomerRepo _repository;

  CustomerListUseCase(this._repository);

  @override
  Future<Either<Failure, CustomerListResponse>> call(params) async {
    return await _repository.getCustomerList(params.page, params.searchQuery);
  }
}

class CustomerUsecaseParams {
  final String page;
  final String? searchQuery;

  CustomerUsecaseParams({required this.page, this.searchQuery});
}