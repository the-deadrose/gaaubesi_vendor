import 'package:gaaubesi_vendor/features/extra_mileage/domain/entity/extra_mileage_list_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'extra_mileage_list_model.g.dart';  

@JsonSerializable()
class ExtraMileageResponseListModel {
  @JsonKey(name: 'count')
  final int count;
  
  @JsonKey(name: 'next')
  final String? next;
  
  @JsonKey(name: 'previous')
  final String? previous;
  
  @JsonKey(name: 'results')
  final List<ExtraMileageResponseModel> results;

  ExtraMileageResponseListModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory ExtraMileageResponseListModel.fromJson(Map<String, dynamic> json) =>
      _$ExtraMileageResponseListModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExtraMileageResponseListModelToJson(this);

  ExtraMileageResponseListEntity toEntity() {
    return ExtraMileageResponseListEntity(
      count: count,
      next: next,
      previous: previous,
      results: results.map((e) => e.toEntity()).toList(),
    );
  }

  factory ExtraMileageResponseListModel.fromEntity(ExtraMileageResponseListEntity entity) {
    return ExtraMileageResponseListModel(
      count: entity.count,
      next: entity.next,
      previous: entity.previous,
      results: entity.results.map((e) => ExtraMileageResponseModel.fromEntity(e)).toList(),
    );
  }
}

@JsonSerializable()
class ExtraMileageResponseModel {
  @JsonKey(name: 'pk')
  final int pk;
  
  @JsonKey(name: 'order')
  final String order;
  
  @JsonKey(name: 'destination')
  final String destination;
  
  @JsonKey(name: 'location')
  final String location;
  
  @JsonKey(name: 'extra_km')
  final int extraKm;

  ExtraMileageResponseModel({
    required this.pk,
    required this.order,
    required this.destination,
    required this.location,
    required this.extraKm,
  });

  factory ExtraMileageResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ExtraMileageResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExtraMileageResponseModelToJson(this);

  ExtraMileageResponseEntity toEntity() {
    return ExtraMileageResponseEntity(
      pk: pk,
      order: order,
      destination: destination,
      location: location,
      extraKm: extraKm,
    );
  }

  factory ExtraMileageResponseModel.fromEntity(ExtraMileageResponseEntity entity) {
    return ExtraMileageResponseModel(
      pk: entity.pk,
      order: entity.order,
      destination: entity.destination,
      location: entity.location,
      extraKm: entity.extraKm,
    );
  }
}