import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/configure/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/resources/data/model/resources_list_model.dart';
import 'package:gaaubesi_vendor/features/resources/domain/entity/resources_list_entity.dart';
import 'package:injectable/injectable.dart';

abstract class ResourcesDatasource {
  Future<Either<Failure, ResourcesListEntity>> fetchResourcesList({
    String? searchQuery,
    String page
  });
}

@LazySingleton(as : ResourcesDatasource)


class ResourcesDatasourceImpl implements ResourcesDatasource {

  final DioClient _dioClient;

  ResourcesDatasourceImpl(this._dioClient);

  @override
  Future<Either<Failure, ResourcesListEntity>> fetchResourcesList({
    String? searchQuery,
    String page = '1',
  }) async {
    try {
      final queryParameters = {
        'page': page,
        if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery,
      };

      final response = await _dioClient.get(
        ApiEndpoints.resourcesList,
        queryParameters: queryParameters,
      );

      final data = response.data;
      if (data != null) {
        final resourcesListModel =
            ResourcesListModel.fromJson(data as Map<String, dynamic>);
        return Right(resourcesListModel);
      } else {
        return Left(ServerFailure('No response data found'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  } 
}