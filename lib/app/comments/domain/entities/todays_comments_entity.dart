import 'package:equatable/equatable.dart';

class TodaysCommentsEntity extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<TodaysCommentsEntities> results;
  final ResponseMetadataEntity metadata;

  const TodaysCommentsEntity({
    required this.count,
    this.next,
    this.previous,
    required this.results,
    required this.metadata,
  });

  @override
  List<Object?> get props => [count, next, previous, results, metadata];

  @override
  bool get stringify => true;
}

class TodaysCommentsEntities extends Equatable {
  final int id;
  final String orderId;
  final String orderLink;
  final String comments;
  final String commentScope;
  final String commentType;
  final String commentTypeDisplay;
  final String status;
  final String statusDisplay;
  final String addedByName;
  final String addedByRole;
  final String createdOn;
  final String createdOnFormatted;
  final String branchName;
  final bool hasChildComments;
  final List<TodaysCommentsEntities> childComments;
  final bool canReply;
  final bool isImportant;

  const TodaysCommentsEntities({
    required this.id,
    required this.orderId,
    required this.orderLink,
    required this.comments,
    required this.commentScope,
    required this.commentType,
    required this.commentTypeDisplay,
    required this.status,
    required this.statusDisplay,
    required this.addedByName,
    required this.addedByRole,
    required this.createdOn,
    required this.createdOnFormatted,
    required this.branchName,
    required this.hasChildComments,
    required this.childComments,
    required this.canReply,
    required this.isImportant,
  });

  @override
  List<Object> get props => [
        id,
        orderId,
        orderLink,
        comments,
        commentScope,
        commentType,
        commentTypeDisplay,
        status,
        statusDisplay,
        addedByName,
        addedByRole,
        createdOn,
        createdOnFormatted,
        branchName,
        hasChildComments,
        childComments,
        canReply,
        isImportant,
      ];

  @override
  bool get stringify => true;
}

class ResponseMetadataEntity extends Equatable {
  final bool todayMode;
  final int totalCount;
  final FiltersEntity filtersApplied;

  const ResponseMetadataEntity({
    required this.todayMode,
    required this.totalCount,
    required this.filtersApplied,
  });

  @override
  List<Object> get props => [todayMode, totalCount, filtersApplied];

  @override
  bool get stringify => true;
}

class FiltersEntity extends Equatable {
  final String branch;
  final String status;
  final String keyword;

  const FiltersEntity({
    required this.branch,
    required this.status,
    required this.keyword,
  });

  @override
  List<Object> get props => [branch, status, keyword];

  @override
  bool get stringify => true;
}