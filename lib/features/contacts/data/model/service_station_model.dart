import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/service_station_entity.dart';

part 'service_station_model.g.dart';

@JsonSerializable()
class ServiceStationListModel extends Equatable {
  final int count;
  final String? next;
  final String? previous;

  @JsonKey(defaultValue: [])
  final List<ServiceStationModel> results;

  const ServiceStationListModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory ServiceStationListModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceStationListModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceStationListModelToJson(this);

  ServiceStationListEntity toEntity() {
    return ServiceStationListEntity(
      count: count,
      next: next,
      previous: previous,
      results: results.map((e) => e.toEntity()).toList(),
    );
  }

  @override
  List<Object?> get props => [count, next, previous, results];
}

@JsonSerializable()
class ServiceStationModel extends Equatable {
  final String name;
  final String district;

  @JsonKey(name: 'phone_numbers', defaultValue: {})
  final Map<String, String> phoneNumbers;

  @JsonKey(name: 'base_charge')
  final double baseCharge;

  @JsonKey(name: 'area_covered')
  final String areaCovered;

  @JsonKey(name: 'arrival_time')
  final String arrivalTime;

  const ServiceStationModel({
    required this.name,
    required this.district,
    required this.phoneNumbers,
    required this.baseCharge,
    required this.areaCovered,
    required this.arrivalTime,
  });

  factory ServiceStationModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceStationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceStationModelToJson(this);

  ServiceStationEntity toEntity() {
    return ServiceStationEntity(
      name: name,
      district: district,
      phoneNumbers: phoneNumbers,
      baseCharge: baseCharge,
      areaCovered: areaCovered,
      arrivalTime: arrivalTime,
    );
  }

  @override
  List<Object?> get props => [
    name,
    district,
    phoneNumbers,
    baseCharge,
    areaCovered,
    arrivalTime,
  ];
}
