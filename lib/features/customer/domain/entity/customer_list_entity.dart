import 'package:equatable/equatable.dart';

class CustomerListResponse extends Equatable {
  final List<CustomerList> customers;
  final int currentPage;
  final int totalPages;
  final int totalCount;

  const CustomerListResponse({
    required this.customers,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
  });

  @override
  List<Object?> get props => [customers, currentPage, totalPages, totalCount];
}

class CustomerList extends Equatable {
  final int id;
  final String name;
  final String phoneNumber;
  final String alternativePhoneNumber;
  final String email;
  final int packageDeliveredCount;
  final DateTime createdOn;

  const CustomerList({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.alternativePhoneNumber,
    required this.email,
    required this.packageDeliveredCount,
    required this.createdOn,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    phoneNumber,
    alternativePhoneNumber,
    email,
    packageDeliveredCount,
    createdOn,
  ];
}
