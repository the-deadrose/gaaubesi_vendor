import 'package:json_annotation/json_annotation.dart';

part 'api_response_model.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponseModel<T> {
  final bool success;
  final String message;
  @JsonKey(defaultValue: null)
  final T? data;

  const ApiResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ApiResponseModelFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T) toJsonT) =>
      _$ApiResponseModelToJson(this, toJsonT);

  factory ApiResponseModel.success({
    required String message,
    T? data,
  }) =>
      ApiResponseModel(
        success: true,
        message: message,
        data: data,
      );

  factory ApiResponseModel.error({
    required String message,
    T? data,
  }) =>
      ApiResponseModel(
        success: false,
        message: message,
        data: data,
      );

  bool isSuccess() => success == true;

  bool isError() => success == false;
}
