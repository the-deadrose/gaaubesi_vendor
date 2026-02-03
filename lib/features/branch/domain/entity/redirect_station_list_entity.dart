import 'package:equatable/equatable.dart';

class RedirectStationListEntity extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<RedirectStationEntity> results;

  const RedirectStationListEntity({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  @override
  List<Object?> get props => [count, next, previous, results];
}

class RedirectStationEntity extends Equatable {
  final int id;
  final BranchEntity homeBranch;
  final List<BranchEntity> redirectBranches;

  const RedirectStationEntity({
    required this.id,
    required this.homeBranch,
    required this.redirectBranches,
  });

  @override
  List<Object?> get props => [id, homeBranch, redirectBranches];
}

class BranchEntity extends Equatable {
  final int id;
  final String name;
  final String code;
  final String district;
  final String province;

  const BranchEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.district,
    required this.province,
  });

  @override
  List<Object?> get props => [id, name, code, district, province];
}