import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _DropdownFilter(
                  label: 'Source Branch',
                  value: selectedSourceBranch,
                  items: const [
                    'Kathmandu',
                    'Pokhara',
                    'Chitwan',
                    'Butwal',
                    'Biratnagar',
                  ], // Mock data
                  onChanged: (value) => onFilterChanged(sourceBranch: value),
                  icon: Icons.location_on_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DropdownFilter(
                  label: 'Dest. Branch',
                  value: selectedDestinationBranch,
                  items: const [
                    'Kathmandu',
                    'Pokhara',
                    'Chitwan',
                    'Butwal',
                    'Biratnagar',
                  ], // Mock data
                  onChanged: (value) =>
                      onFilterChanged(destinationBranch: value),
                  icon: Icons.location_on,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DateRangeFilter(
                  startDate: selectedStartDate,
                  endDate: selectedEndDate,
                  onChanged: (start, end) =>
                      onFilterChanged(startDate: start, endDate: end),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DropdownFilter(
                  label: 'Status',
                  value: selectedStatus,
                  items: const [
                    'Pending',
                    'In Transit',
                    'Delivered',
                    'Cancelled',
                    'Returned',
                  ],
                  onChanged: (value) => onFilterChanged(
                    status: value?.toLowerCase().replaceAll(' ', '_'),
                  ),
                  icon: Icons.info_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final IconData icon;

  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          hint: Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: Colors.grey[600],
          ),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'All $label',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ...items.map((item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DateRangeFilter extends StatelessWidget {
  final String? startDate;
  final String? endDate;
  final Function(String?, String?) onChanged;

  const _DateRangeFilter({
    this.startDate,
    this.endDate,
    required this.onChanged,
  });

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Theme.of(context).scaffoldBackgroundColor,
              onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final start = DateFormat('yyyy-MM-dd').format(picked.start);
      final end = DateFormat('yyyy-MM-dd').format(picked.end);
      onChanged(start, end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasDate = startDate != null && endDate != null;

    return GestureDetector(
      onTap: () => _selectDateRange(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: hasDate ? theme.primaryColor : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasDate ? '$startDate - $endDate' : 'Date Range',
                style: TextStyle(
                  fontSize: 13,
                  color: hasDate
                      ? (isDark ? Colors.white : Colors.black87)
                      : Colors.grey[600],
                  fontWeight: hasDate ? FontWeight.w500 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasDate)
              GestureDetector(
                onTap: () => onChanged(null, null),
                child: Icon(Icons.close, size: 16, color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }
}
