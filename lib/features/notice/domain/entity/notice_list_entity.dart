import 'package:equatable/equatable.dart';

class NoticeListResponse extends Equatable {
  final List<Notice> notices;
  final int count;
  final String? next;
  final String? previous;

  const NoticeListResponse({
    required this.notices,
    required this.count,
    this.next,
    this.previous,
  });

  @override
  List<Object?> get props => [notices, count, next, previous];
}

class Notice extends Equatable {
  final int id;
  final String title;
  final String content;
  final DateTime createdOn;
  final String createdOnFormatted;
  final String createdByName;
  final bool isRead;
  final bool isPopup;

  const Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.createdOn,
    required this.createdOnFormatted,
    required this.createdByName,
    required this.isRead,
    required this.isPopup,
  });

  Notice copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? createdOn,
    String? createdOnFormatted,
    String? createdByName,
    bool? isRead,
    bool? isPopup,
  }) {
    return Notice(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdOn: createdOn ?? this.createdOn,
      createdOnFormatted: createdOnFormatted ?? this.createdOnFormatted,
      createdByName: createdByName ?? this.createdByName,
      isRead: isRead ?? this.isRead,
      isPopup: isPopup ?? this.isPopup,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    createdOn,
    createdOnFormatted,
    createdByName,
    isRead,
    isPopup,
  ];
}