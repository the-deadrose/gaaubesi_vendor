import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/customer/domain/entity/customer_list_entity.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerListLoading extends CustomerState {}

class CustomerListLoaded extends CustomerState {
  final List<CustomerList> customers;
  final int currentPage;
  final int totalPages;
  final bool hasReachedMax;
  final bool isSearchResult;

  const CustomerListLoaded({
    required this.customers,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasReachedMax = false,
    this.isSearchResult = false,
  });

  CustomerListLoaded copyWith({
    List<CustomerList>? customers,
    int? currentPage,
    int? totalPages,
    bool? hasReachedMax,
    bool? isSearchResult,
  }) {
    return CustomerListLoaded(
      customers: customers ?? this.customers,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isSearchResult: isSearchResult ?? this.isSearchResult,
    );
  }

  @override
  List<Object?> get props => [
        customers,
        currentPage,
        totalPages,
        hasReachedMax,
        isSearchResult,
      ];
}

class CustomerListError extends CustomerState {
  final String message;

  const CustomerListError(this.message);

  @override
  List<Object?> get props => [message];
}



class CustomerSearching extends CustomerState {}

class CustomerSearchLoaded extends CustomerState {
  final List<CustomerList> customers;

  const CustomerSearchLoaded({required this.customers});

  @override
  List<Object?> get props => [customers];
}

class CustomerSearchError extends CustomerState {
  final String message;

  const CustomerSearchError(this.message);

  @override
  List<Object?> get props => [message];
}

class CustomerListPaginating extends CustomerState {}

class CustomerListPaginated extends CustomerState{
  final CustomerList customer;
  const CustomerListPaginated({required this.customer});
  @override
  List<Object?> get props => [customer];

}

class CustomerListPaginationError extends CustomerState {
  final String message;

  const CustomerListPaginationError(this.message);

  @override
  List<Object?> get props => [message];
}