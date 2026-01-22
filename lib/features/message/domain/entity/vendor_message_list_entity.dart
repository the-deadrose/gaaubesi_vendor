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
