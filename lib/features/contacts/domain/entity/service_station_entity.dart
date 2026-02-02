import 'package:equatable/equatable.dart';

class ServiceStationEntity extends Equatable {
  final String name;
  final String district;
  final Map<String, String> phoneNumbers;
  final double baseCharge;
  final String areaCovered;
  final String arrivalTime;

  const ServiceStationEntity({
    required this.name,
    required this.district,
    required this.phoneNumbers,
    required this.baseCharge,
    required this.areaCovered,
    required this.arrivalTime,
  });

  @override
  List<Object?> get props => [
    name,
    district,
    phoneNumbers,
    baseCharge,
    areaCovered,
    arrivalTime,
  ];

  @override
  bool get stringify => true;

  ServiceStationEntity copyWith({
    String? name,
    String? district,
    Map<String, String>? phoneNumbers,
    double? baseCharge,
    String? areaCovered,
    String? arrivalTime,
  }) {
    return ServiceStationEntity(
      name: name ?? this.name,
      district: district ?? this.district,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      baseCharge: baseCharge ?? this.baseCharge,
      areaCovered: areaCovered ?? this.areaCovered,
      arrivalTime: arrivalTime ?? this.arrivalTime,
    );
  }
}

class ServiceStationListEntity extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<ServiceStationEntity> results;

  const ServiceStationListEntity({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  @override
  List<Object?> get props => [count, next, previous, results];

  @override
  bool get stringify => true;

  ServiceStationListEntity copyWith({
    int? count,
    String? next,
    String? previous,
    List<ServiceStationEntity>? results,
  }) {
    return ServiceStationListEntity(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }
}
