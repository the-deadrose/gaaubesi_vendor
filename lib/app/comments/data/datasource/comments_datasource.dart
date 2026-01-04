import 'package:gaaubesi_vendor/app/comments/data/model/todays_comments_model.dart';
import 'package:gaaubesi_vendor/app/comments/domain/entities/todays_comments_entity.dart';
import 'package:gaaubesi_vendor/app/comments/domain/repository/comments_repository.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:injectable/injectable.dart';

abstract class CommentsDatasource {
  Future<TodaysCommentsEntity> fetchTodaysComments({required String page});
}

@LazySingleton(as: CommentsDatasource)
class CommentsDataSourceImps implements CommentsDatasource {
  final DioClient _dioClient;
  CommentsDataSourceImps(this._dioClient);
  @override
  Future<TodaysCommentsEntity> fetchTodaysComments({
    required String page,
  }) async {
    final response = await _dioClient.get(
      '/comments/today/',
      queryParameters: {'page': page},
    );

    if (response.statusCode == 200) {
      return TodaysCommentsModel.fromJson(response.data);
    } else {
      throw ServerException('Failed to fetch today\'s comments');
    }
  }
}
