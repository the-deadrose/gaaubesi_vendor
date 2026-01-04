import 'package:gaaubesi_vendor/app/comments/domain/entities/todays_comments_entity.dart';

extension TodaysCommentsModel on TodaysCommentsEntity {
  static TodaysCommentsEntity fromJson(Map<String, dynamic> json) {
    return TodaysCommentsEntity(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List)
          .map((item) => TodaysCommentsEntitiesModel.fromJson(item))
          .toList(),
      metadata: ResponseMetadataModel.fromJson(json['metadata']),
    );
  }
}

extension TodaysCommentsEntitiesModel on TodaysCommentsEntities {
  static TodaysCommentsEntities fromJson(Map<String, dynamic> json) {
    return TodaysCommentsEntities(
      id: json['id'] as int,
      orderId: json['order_id'] as String,
      orderLink: json['order_link'] as String,
      comments: json['comments'] as String,
      commentScope: json['comment_scope'] as String,
      commentType: json['comment_type'] as String,
      commentTypeDisplay: json['comment_type_display'] as String,
      status: json['status'] as String,
      statusDisplay: json['status_display'] as String,
      addedByName: json['added_by_name'] as String,
      addedByRole: json['added_by_role'] as String,
      createdOn: json['created_on'] as String,
      createdOnFormatted: json['created_on_formatted'] as String,
      branchName: json['branch_name'] as String,
      hasChildComments: json['has_child_comments'] as bool,
      childComments: (json['child_comments'] as List)
          .map((item) => TodaysCommentsEntitiesModel.fromJson(item))
          .toList(),
      canReply: json['can_reply'] as bool,
      isImportant: json['is_important'] as bool,
    );
  }
}

extension ResponseMetadataModel on ResponseMetadataEntity {
  static ResponseMetadataEntity fromJson(Map<String, dynamic> json) {
    return ResponseMetadataEntity(
      todayMode: json['today_mode'] as bool,
      totalCount: json['total_count'] as int,
      filtersApplied: FiltersModel.fromJson(json['filters_applied']),
    );
  }
}

extension FiltersModel on FiltersEntity {
  static FiltersEntity fromJson(Map<String, dynamic> json) {
    return FiltersEntity(
      branch: json['branch'] as String,
      status: json['status'] as String,
      keyword: json['keyword'] as String,
    );
  }
}
