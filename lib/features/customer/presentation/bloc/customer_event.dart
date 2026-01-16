import 'package:equatable/equatable.dart';


abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class FetchCustomerList extends CustomerEvent {
  final int page;
  final bool isRefresh;

  const FetchCustomerList({
    this.page = 1,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [page, isRefresh];
}

class LoadMoreCustomerList extends CustomerEvent {
  final int nextPage;

  const LoadMoreCustomerList(this.nextPage);

  @override
  List<Object?> get props => [nextPage];
}

class RefreshCustomerList extends CustomerEvent {
  const RefreshCustomerList();

  @override
  List<Object?> get props => [];
}

class SearchCustomerList extends CustomerEvent {
  final String query;

  const SearchCustomerList(this.query);

  @override
  List<Object?> get props => [query];
}

class CustomerScreenPagination extends CustomerEvent {
  final int page;

  const CustomerScreenPagination(this.page);

  @override
  List<Object?> get props => [page];
}
