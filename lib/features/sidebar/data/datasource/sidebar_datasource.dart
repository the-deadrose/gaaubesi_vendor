import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/configure/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/sidebar/data/datasource/sidebar_local_datasource.dart';
import 'package:gaaubesi_vendor/features/sidebar/data/model/side_bar_model.dart';
import 'package:gaaubesi_vendor/features/sidebar/domain/entity/sidebar_entity.dart';
import 'package:injectable/injectable.dart';

abstract class SidebarDatasource {
  Future<Either<Failure, List<SideBarEntity>>> getSidebarData();
}

@Singleton(as: SidebarDatasource)
class SidebarDatasourceImpl implements SidebarDatasource {
  final DioClient _dioClient;
  final SidebarLocalDatasource _localDatasource;
  SidebarDatasourceImpl(this._dioClient, this._localDatasource);

  @override
  Future<Either<Failure, List<SideBarEntity>>> getSidebarData() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.sidebar);
      
      // Handle if response is a list
      List<SideBarModel> items = [];
      if (response.data is List) {
        items = (response.data as List)
            .map((item) => SideBarModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.data is Map) {
        // Handle if response has data key (like {message: ..., data: [...]})
        if (response.data['data'] != null && response.data['data'] is List) {
          items = (response.data['data'] as List)
              .map((item) => SideBarModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        // Handle if response has items key
        else if (response.data['items'] != null && response.data['items'] is List) {
          items = (response.data['items'] as List)
              .map((item) => SideBarModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      
      // Cache the fetched data
      if (items.isNotEmpty) {
        await _localDatasource.cacheSidebarData(items);
      }
      
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
