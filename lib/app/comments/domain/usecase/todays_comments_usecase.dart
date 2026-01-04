import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/app/comments/domain/entities/todays_comments_entity.dart';
import 'package:gaaubesi_vendor/app/comments/domain/repository/comments_repository.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:injectable/injectable.dart';

class TodaysCommentsParams {
  final String page;

  TodaysCommentsParams({required this.page});
}

@lazySingleton
class TodaysCommentsUseCase
    extends UseCase<TodaysCommentsEntity, TodaysCommentsParams> {
  final CommentsRepository repository;

  TodaysCommentsUseCase(this.repository);

  @override
  Future<Either<Failure, TodaysCommentsEntity>> call(
    TodaysCommentsParams params,
  ) async {
    return await repository.fetchTodaysComments(page: params.page);
  }
}