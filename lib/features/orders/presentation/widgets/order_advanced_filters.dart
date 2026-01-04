import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/filters/date_range_filter.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/filters/dropdown_filter.dart';

/// Advanced filters widget for filtering orders by various criteria.
class OrderAdvancedFilters extends StatelessWidget {
  final String? selectedSourceBranch;
  final String? selectedDestinationBranch;
  final String? selectedStartDate;
  final String? selectedEndDate;
  final String? selectedStatus;
  final Function({
    String? sourceBranch,
    String? destinationBranch,
    String? startDate,
    String? endDate,
    String? status,
  })
  onFilterChanged;

  const OrderAdvancedFilters({
    super.key,
    this.selectedSourceBranch,
    this.selectedDestinationBranch,
    this.selectedStartDate,
    this.selectedEndDate,
    this.selectedStatus,
    required this.onFilterChanged,
  });

  static const _branchItems = [
    'Kathmandu',
    'Pokhara',
    'Chitwan',
    'Butwal',
    'Biratnagar',
  ];

  static const _statusItems = [
    'Pending',
    'In Transit',
    'Delivered',
    'Cancelled',
    'Returned',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBranchFilters(),
          const SizedBox(height: 12),
          _buildDateAndStatusFilters(),
        ],
      ),
    );
  }

  Widget _buildBranchFilters() {
    return Row(
      children: [
        Expanded(
          child: DropdownFilter(
            label: 'Source Branch',
            value: selectedSourceBranch,
            items: _branchItems,
            onChanged: (value) => onFilterChanged(sourceBranch: value),
            icon: Icons.location_on_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownFilter(
            label: 'Dest. Branch',
            value: selectedDestinationBranch,
            items: _branchItems,
            onChanged: (value) => onFilterChanged(destinationBranch: value),
            icon: Icons.location_on,
          ),
        ),
      ],
    );
  }

  Widget _buildDateAndStatusFilters() {
    return Row(
      children: [
        Expanded(
          child: DateRangeFilter(
            startDate: selectedStartDate,
            endDate: selectedEndDate,
            onChanged: (start, end) =>
                onFilterChanged(startDate: start, endDate: end),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownFilter(
            label: 'Status',
            value: selectedStatus,
            items: _statusItems,
            onChanged: (value) => onFilterChanged(
              status: value?.toLowerCase().replaceAll(' ', '_'),
            ),
            icon: Icons.info_outline,
          ),
        ),
      ],
    );
  }
}
