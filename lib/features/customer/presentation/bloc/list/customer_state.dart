import 'package:equatable/equatable.dart';
import 'package:gaaubesi_vendor/features/customer/domain/entity/customer_list_entity.dart';

abstract class CustomerListState extends Equatable {
  const CustomerListState();

  @override
  List<Object?> get props => [];
}

class CustomerListInitial extends CustomerListState {}

class CustomerListLoading extends CustomerListState {}

class CustomerListLoaded extends CustomerListState {
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

class CustomerListError extends CustomerListState {
  final String message;

  const CustomerListError(this.message);

  @override
  List<Object?> get props => [message];
}

class CustomerListSearching extends CustomerListState {}

class CustomerListSearchLoaded extends CustomerListState {
  final List<CustomerList> customers;

  const CustomerListSearchLoaded({required this.customers});

  @override
  List<Object?> get props => [customers];
}

class CustomerListSearchError extends CustomerListState {
  final String message;

  const CustomerListSearchError(this.message);

  @override
  List<Object?> get props => [message];
}

class CustomerListPaginating extends CustomerListState {}

class CustomerListPaginationError extends CustomerListState {
  final String message;

  const CustomerListPaginationError(this.message);

  @override
  List<Object?> get props => [message];
}