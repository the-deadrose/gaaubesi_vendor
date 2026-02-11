import 'package:equatable/equatable.dart';

class ResourcesListEntity extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<ResourceItemEntity> results;

  const ResourcesListEntity({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  @override
  List<Object?> get props => [
        count,
        next,
        previous,
        results,
      ];
}

class ResourceItemEntity extends Equatable {
  final String title;
  final String description;
  final String view;

  const ResourceItemEntity({
    required this.title,
    required this.description,
    required this.view,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        view,
      ];
}
