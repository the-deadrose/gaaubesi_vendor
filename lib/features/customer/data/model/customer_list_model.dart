import 'package:gaaubesi_vendor/features/customer/domain/entity/customer_list_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'customer_list_model.g.dart';

@JsonSerializable()
class CustomerListModel {
  final int id;
  final String? name;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(name: 'alternative_phone_number')
  final String? alternativePhoneNumber;
  final String? email;
  @JsonKey(name: 'package_delivered_count')
  final int? packageDeliveredCount;
  @JsonKey(name: 'created_on')
  final DateTime? createdOn;

  const CustomerListModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.alternativePhoneNumber,
    required this.email,
    required this.packageDeliveredCount,
    required this.createdOn,
  });

  factory CustomerListModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerListModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerListModelToJson(this);

  // Convert to entity with non-null values
  CustomerList toEntity() {
    return CustomerList(
      id: id,
      name: name ?? '',
      phoneNumber: phoneNumber ?? '',
      alternativePhoneNumber: alternativePhoneNumber ?? '',
      email: email ?? '',
      packageDeliveredCount: packageDeliveredCount ?? 0,
      createdOn: createdOn ?? DateTime.now(),
    );
  }

  // Convert from entity
  factory CustomerListModel.fromEntity(CustomerList entity) {
    return CustomerListModel(
      id: entity.id,
      name: entity.name,
      phoneNumber: entity.phoneNumber,
      alternativePhoneNumber: entity.alternativePhoneNumber,
      email: entity.email,
      packageDeliveredCount: entity.packageDeliveredCount,
      createdOn: entity.createdOn,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CustomerListResponseModel {
  @JsonKey(name: 'results', defaultValue: [])
  final List<CustomerListModel> customers;
  @JsonKey(name: 'count', defaultValue: 0)
  final int totalCount;
  @JsonKey(name: 'next')
  final String? next;
  @JsonKey(name: 'previous')
  final String? previous;

  const CustomerListResponseModel({
    required this.customers,
    required this.totalCount,
    this.next,
    this.previous,
  });

  factory CustomerListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerListResponseModelToJson(this);

  // Convert to entity
  CustomerListResponse toEntity(int requestedPage) {
    // Calculate total pages (assuming 10 items per page, adjust if different)
    const itemsPerPage = 10;
    final calculatedTotalPages = (totalCount / itemsPerPage).ceil();
    
    return CustomerListResponse(
      customers: customers.map((e) => e.toEntity()).toList(),
      currentPage: requestedPage,
      totalPages: calculatedTotalPages,
      totalCount: totalCount,
    );
  }

  // Convert from entity
  factory CustomerListResponseModel.fromEntity(CustomerListResponse entity) {
    return CustomerListResponseModel(
      customers: entity.customers.map(CustomerListModel.fromEntity).toList(),
      totalCount: entity.totalCount,
      next: null,
      previous: null,
    );
  }
}