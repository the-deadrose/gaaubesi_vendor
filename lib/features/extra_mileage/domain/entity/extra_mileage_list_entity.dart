import 'package:equatable/equatable.dart';

class ExtraMileageResponseListEntity extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<ExtraMileageResponseEntity> results;

  const ExtraMileageResponseListEntity({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory ExtraMileageResponseListEntity.fromJson(Map<String, dynamic> json) {
    return ExtraMileageResponseListEntity(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((item) => ExtraMileageResponseEntity.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((e) => e.toJson()).toList(),
    };
  }

  ExtraMileageResponseListEntity copyWith({
    int? count,
    String? next,
    String? previous,
    List<ExtraMileageResponseEntity>? results,
  }) {
    return ExtraMileageResponseListEntity(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }

  @override
  List<Object?> get props => [count, next, previous, results];

  @override
  bool get stringify => true;
}

class ExtraMileageResponseEntity extends Equatable {
  final int pk;
  final String order;
  final String destination;
  final String location;
  final int extraKm;

  const ExtraMileageResponseEntity({
    required this.pk,
    required this.order,
    required this.destination,
    required this.location,
    required this.extraKm,
  });

  factory ExtraMileageResponseEntity.fromJson(Map<String, dynamic> json) {
    return ExtraMileageResponseEntity(
      pk: json['pk'] as int,
      order: json['order'] as String,
      destination: json['destination'] as String,
      location: json['location'] as String,
      extraKm: json['extra_km'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pk': pk,
      'order': order,
      'destination': destination,
      'location': location,
      'extra_km': extraKm,
    };
  }

  ExtraMileageResponseEntity copyWith({
    int? pk,
    String? order,
    String? destination,
    String? location,
    int? extraKm,
  }) {
    return ExtraMileageResponseEntity(
      pk: pk ?? this.pk,
      order: order ?? this.order,
      destination: destination ?? this.destination,
      location: location ?? this.location,
      extraKm: extraKm ?? this.extraKm,
    );
  }

  @override
  List<Object?> get props => [pk, order, destination, location, extraKm];

  @override
  bool get stringify => true;
}