import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/customer/data/datasource/customer_datasource.dart';
import 'package:gaaubesi_vendor/features/customer/domain/entity/customer_detail_entity.dart';
import 'package:gaaubesi_vendor/features/customer/domain/entity/customer_list_entity.dart';
import 'package:gaaubesi_vendor/features/customer/domain/repository/customer_repo.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CustomerRepo)
class CustomerRepoImp implements CustomerRepo {
  final CustomerRemoteDatasource remoteDataSource;

  CustomerRepoImp({required this.remoteDataSource});

  @override
  Future<Either<Failure, CustomerListResponse>> getCustomerList(String page , String? searchQuery) async {
    try {
      final result = await remoteDataSource.getCustomerList(page, searchQuery);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure('Failed to fetch customer list'));
    }
  }

  @override
  Future<Either<Failure, CustomerDetailEntity>> getCustomerDetail(String customerId) async {
    try {
      final result = await remoteDataSource.getCustomerDetail(customerId);
      return Right(result);
    } on ServerException {  
      return Left(ServerFailure('Failed to fetch customer detail'));
    }
  }
}
