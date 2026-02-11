import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/resources/domain/entity/resources_list_entity.dart';

abstract class ResourcesRepository {
  Future<Either<Failure, ResourcesListEntity>> fetchResourcesList({
    String? searchQuery,
    String page,
  });
}
