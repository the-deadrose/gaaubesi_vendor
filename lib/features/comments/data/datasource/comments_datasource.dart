import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/core/constants/api_endpoints.dart';
import 'package:gaaubesi_vendor/core/error/exceptions.dart';
import 'package:gaaubesi_vendor/core/network/dio_client.dart';
import 'package:gaaubesi_vendor/features/comments/data/model/comments_model.dart';
import 'package:gaaubesi_vendor/features/comments/domain/entity/comments_entity.dart';

abstract class CommentsRemoteDatasource {
  Future<CommentsResponseEntity> fetchTodaysComments(String page);
  Future<CommentsResponseEntity> fetchAllComments(String page);
  Future<void> replyToComment({
    required String commentId,
    required String comment,
  });
  Future<CommentsResponseEntity> fetchCommentsFiltered({
    required String page,
    String? status,
    String? startDate,
    String? endDate,
    String? searchId,
  });
}

@LazySingleton(as: CommentsRemoteDatasource)
class CommentsDatasourceImpl implements CommentsRemoteDatasource {
  CommentsDatasourceImpl(this._dioClient);
  final DioClient _dioClient;

  @override
  Future<CommentsResponseEntity> fetchTodaysComments(String page) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.commentsTodays,
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        final commentsResponse = CommentsResponse.fromJson(response.data);
        return commentsResponse.toEntity();
      } else {
        throw ServerException('Failed to fetch today\'s comments');
      }
    } on DioException catch (e) {
      debugPrint(
        '[COMMENTS_DATASOURCE] DioException: ${e.message}, StatusCode: ${e.response?.statusCode}',
      );
      throw ServerException(
        e.message ?? 'Unknown error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      debugPrint('[COMMENTS_DATASOURCE] Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<CommentsResponseEntity> fetchAllComments(String page) async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.commentsAll,
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        final commentsResponse = CommentsResponse.fromJson(response.data);
        return commentsResponse.toEntity();
      } else {
        throw ServerException('Failed to fetch all comments');
      }
    } on DioException catch (e) {
      debugPrint(
        '[COMMENTS_DATASOURCE] DioException: ${e.message}, StatusCode: ${e.response?.statusCode}',
      );
      throw ServerException(
        e.message ?? 'Unknown error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      debugPrint('[COMMENTS_DATASOURCE] Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<CommentsResponseEntity> fetchCommentsFiltered({
    required String page,
    String? status,
    String? startDate,
    String? endDate,
    String? searchId,
  }) async {
    try {
      final queryParameters = {'page': page};

      if (status != null && status.isNotEmpty && status != 'None') {
        queryParameters['status'] = status;
      }
      if (startDate != null && startDate.isNotEmpty) {
        queryParameters['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        queryParameters['end_date'] = endDate;
      }
      if (searchId != null && searchId.isNotEmpty) {
        queryParameters['search'] = searchId;
      }

      final response = await _dioClient.get(
        ApiEndpoints.commentsAll,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final commentsResponse = CommentsResponse.fromJson(response.data);
        return commentsResponse.toEntity();
      } else {
        throw ServerException('Failed to fetch filtered comments');
      }
    } on DioException catch (e) {
      debugPrint(
        '[COMMENTS_DATASOURCE] DioException: ${e.message}, StatusCode: ${e.response?.statusCode}',
      );
      throw ServerException(
        e.message ?? 'Unknown error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      debugPrint('[COMMENTS_DATASOURCE] Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<void> replyToComment({
    required String commentId,
    required String comment,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.replyToComment,
        data: {'comment_id': commentId, 'comment': comment},
      );

      debugPrint('[COMMENTS_DATASOURCE] Response: ${response.data}');

      if (response.statusCode == 200) {
        // Check if the response indicates success
        if (response.data is Map && response.data['success'] == true) {
          debugPrint('[COMMENTS_DATASOURCE] Reply successful');
          return;
        } else {
          final errorMessage = response.data is Map
              ? response.data['message'] ?? 'Failed to reply to comment'
              : 'Failed to reply to comment: Invalid response';
          debugPrint('[COMMENTS_DATASOURCE] API returned error: $errorMessage');
          throw ServerException(errorMessage);
        }
      } else {
        throw ServerException('Failed to reply to comment: Status code ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint(
        '[COMMENTS_DATASOURCE] DioException: ${e.message}, StatusCode: ${e.response?.statusCode}',
      );
      throw ServerException(
        e.message ?? 'Unknown error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      debugPrint('[COMMENTS_DATASOURCE] Unexpected error: $e');
      // Don't rethrow the exception, instead convert it to a ServerException
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }
}
