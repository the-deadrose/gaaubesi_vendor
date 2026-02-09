import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/features/sidebar/domain/entity/sidebar_entity.dart';

abstract class SidebarRepository {
  Future<Either<Failure, List<SideBarEntity>>> getSidebarData();
}
