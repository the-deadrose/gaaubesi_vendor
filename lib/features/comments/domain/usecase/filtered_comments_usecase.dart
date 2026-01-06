import 'package:fpdart/fpdart.dart';
import 'package:gaaubesi_vendor/core/error/failures.dart';
import 'package:gaaubesi_vendor/core/usecase/base_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/features/comments/domain/entity/comments_entity.dart';
import 'package:gaaubesi_vendor/features/comments/domain/repository/comments_repository.dart';

class FilteredCommentsParams {
  final String page;
  final String? status;
  final String? startDate;
  final String? endDate;
  final String? searchId;

  FilteredCommentsParams({
    required this.page,
    this.status,
    this.startDate,
    this.endDate,
    this.searchId,
  });
}

@lazySingleton
class FilteredCommentsUsecase
    implements UseCase<CommentsResponseEntity, FilteredCommentsParams> {
  final CommentsRepository _repository;

  FilteredCommentsUsecase(this._repository);

  @override
  Future<Either<Failure, CommentsResponseEntity>> call(
    FilteredCommentsParams params,
  ) async {
    final result = await _repository.filteredComments(
      page: params.page,
      status: params.status,
      startDate: params.startDate,
      endDate: params.endDate,
      searchId: params.searchId,
    );
    return result;
  }
}
