import 'package:equatable/equatable.dart';

class BranchReportAnalysisEntity extends Equatable {
  final int destinationBranch;
  final String name;
  final int total;
  final int processingOrders;
  final int delivered;
  final int returned;

  const BranchReportAnalysisEntity({
    required this.destinationBranch,
    required this.name,
    required this.total,
    required this.processingOrders,
    required this.delivered,
    required this.returned,
  });

  @override
  List<Object?> get props => [
        destinationBranch,
        name,
        total,
        processingOrders,
        delivered,
        returned,
      ];

  @override
  bool get stringify => true;

  BranchReportAnalysisEntity copyWith({
    int? destinationBranch,
    String? name,
    int? total,
    int? processingOrders,
    int? delivered,
    int? returned,
  }) {
    return BranchReportAnalysisEntity(
      destinationBranch: destinationBranch ?? this.destinationBranch,
      name: name ?? this.name,
      total: total ?? this.total,
      processingOrders: processingOrders ?? this.processingOrders,
      delivered: delivered ?? this.delivered,
      returned: returned ?? this.returned,
    );
  }
}