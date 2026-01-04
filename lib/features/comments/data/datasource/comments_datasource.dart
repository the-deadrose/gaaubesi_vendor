import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/comments/data/model/comments_model.dart';
import 'package:gaaubesi_vendor/features/comments/domain/entity/comments_entity.dart';

abstract class CommentsRemoteDatasource {
  Future<CommentsResponseEntity> fetchTodaysComments(String page);
  Future<CommentsResponseEntity> fetchAllComments(String page);
}

@LazySingleton(as: CommentsRemoteDatasource)
class CommentsDatasourceImpl implements CommentsRemoteDatasource {
  CommentsDatasourceImpl(this._dioClient);
  final DioClient _dioClient;

  @override
  Future<CommentsResponseEntity> fetchTodaysComments(String page) async {
    try {
      final response = await _dioClient.get(ApiEndpoints.commentsTodays);
      if (response.statusCode == 200) {
        final commentsResponse = CommentsResponse.fromJson(response.data);
        return commentsResponse.toEntity();
      } else {
        throw ServerException('Failed to fetch today\'s comments');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Unknown error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<CommentsResponseEntity> fetchAllComments(String page) async {
    try {
      final response = await _dioClient.get(ApiEndpoints.commentsAll);
      if (response.statusCode == 200) {
        final commentsResponse = CommentsResponse.fromJson(response.data);
        return commentsResponse.toEntity();
      } else {
        throw ServerException('Failed to fetch all comments');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Unknown error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
