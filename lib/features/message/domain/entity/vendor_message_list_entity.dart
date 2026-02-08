import 'package:equatable/equatable.dart';

class VendorMessageListEntity extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<VendorMessageEntity> results;

  const VendorMessageListEntity({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  @override
  List<Object?> get props => [count, next, previous, results];
}

class VendorMessageEntity extends Equatable {
  final int id;
  final String message;
  final DateTime createdOn;
  final String createdOnFormatted;
  final String createdByName;
  final bool isRead;

  const VendorMessageEntity({
    required this.id,
    required this.message,
    required this.createdOn,
    required this.createdOnFormatted,
    required this.createdByName,
    required this.isRead,
  });

  VendorMessageEntity copyWith({
    int? id,
    String? message,
    DateTime? createdOn,
    String? createdOnFormatted,
    String? createdByName,
    bool? isRead,
  }) {
    return VendorMessageEntity(
      id: id ?? this.id,
      message: message ?? this.message,
      createdOn: createdOn ?? this.createdOn,
      createdOnFormatted: createdOnFormatted ?? this.createdOnFormatted,
      createdByName: createdByName ?? this.createdByName,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [
        id,
        message,
        createdOn,
        createdOnFormatted,
        createdByName,
        isRead,
      ];
}
