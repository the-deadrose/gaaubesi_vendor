import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/features/comments/domain/entity/comments_entity.dart';
import 'package:gaaubesi_vendor/features/comments/domain/repository/comments_repository.dart';

@lazySingleton
class TodaysCommentsUsecase implements UseCase<CommentsResponseEntity, String> {
  final CommentsRepository _repository;

  TodaysCommentsUsecase(this._repository);

  @override
  Future<Either<Failure, CommentsResponseEntity>> call(String page) async {
    final result = await _repository.todaysComments(page);
    return result;
  }
}