import 'package:equatable/equatable.dart';

abstract class CustomerListEvent extends Equatable {
  const CustomerListEvent();

  @override
  List<Object?> get props => [];
}

class FetchCustomerList extends CustomerListEvent {
  final int page;
  final bool isRefresh;

  const FetchCustomerList({
    this.page = 1,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [page, isRefresh];
}

class LoadMoreCustomerList extends CustomerListEvent {
  final int nextPage;

  const LoadMoreCustomerList(this.nextPage);

  @override
  List<Object?> get props => [nextPage];
}

class RefreshCustomerList extends CustomerListEvent {
  const RefreshCustomerList();

  @override
  List<Object?> get props => [];
}

class SearchCustomerList extends CustomerListEvent {
  final String query;

  const SearchCustomerList(this.query);

  @override
  List<Object?> get props => [query];
}

class CustomerListScreenPagination extends CustomerListEvent {
  final int page;

  const CustomerListScreenPagination(this.page);

  @override
  List<Object?> get props => [page];
}

class ResetCustomerListState extends CustomerListEvent {
  const ResetCustomerListState();

  @override
  List<Object?> get props => [];
}