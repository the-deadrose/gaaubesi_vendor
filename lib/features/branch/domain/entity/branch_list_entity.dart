import 'package:equatable/equatable.dart';

class BranchListEntity extends Equatable {
  final String value; // Branch ID as string
  final String label; // Display name
  final String code; // Branch code (e.g., "RTPL", "ATRY")

  const BranchListEntity({
    required this.value,
    required this.label,
    required this.code,
  });

  @override
  List<Object?> get props => [value, label, code];
}
