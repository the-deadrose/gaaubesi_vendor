import 'package:equatable/equatable.dart';

abstract class SubBranchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchSubBranchesEvent extends SubBranchEvent {
  final String page;
  final String? searchQuery;

  FetchSubBranchesEvent({required this.page, this.searchQuery});

  @override
  List<Object?> get props => [page, searchQuery];
}

class RefreshSubBranchesEvent extends SubBranchEvent {
  final String page;
  final String? searchQuery;

  RefreshSubBranchesEvent({required this.page, this.searchQuery});

  @override
  List<Object?> get props => [page, searchQuery];
}
