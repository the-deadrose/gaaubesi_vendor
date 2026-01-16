import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/customer/domain/entity/customer_list_entity.dart';

abstract class CustomerRepo {
  Future<Either<Failure, CustomerListResponse>> getCustomerList(String page , String? searchQuery);
}
