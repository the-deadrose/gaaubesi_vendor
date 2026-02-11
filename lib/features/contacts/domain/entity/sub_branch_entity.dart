import 'package:equatable/equatable.dart';

class SubBranchesEntity extends Equatable {
  final String name;
  final String district;
  final Map<String, String> phoneNumbers;
  final double baseCharge;
  final String areaCovered;
  final String arrivalTime;

  const SubBranchesEntity({
    required this.name,
    required this.district,
    this.phoneNumbers = const {},
    required this.baseCharge,
    required this.areaCovered,
    required this.arrivalTime,
  });

  @override
  List<Object?> get props => [
        name,
        district,
        phoneNumbers,
        baseCharge,
        areaCovered,
        arrivalTime,
      ];
}

class SubBranchesResponseEntity extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<SubBranchesEntity> results;

  const SubBranchesResponseEntity({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  @override
  List<Object?> get props => [
        count,
        next,
        previous,
        results,
      ];
}