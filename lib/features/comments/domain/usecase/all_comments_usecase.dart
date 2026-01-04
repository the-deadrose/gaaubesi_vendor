import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/features/comments/domain/entity/comments_entity.dart';
import 'package:gaaubesi_vendor/features/comments/domain/repository/comments_repository.dart';

@lazySingleton
class AllCommentsUsecase implements UseCase<CommentsResponseEntity, String> {
  final CommentsRepository _repository;

  AllCommentsUsecase(this._repository);

  @override
  Future<Either<Failure, CommentsResponseEntity>> call(String page) async {
    final result = await _repository.allComments(page);
    return result;
  }
}
