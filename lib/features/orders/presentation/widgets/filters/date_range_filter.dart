import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A date range picker filter widget.
class DateRangeFilter extends StatelessWidget {
  final String? startDate;
  final String? endDate;
  final Function(String?, String?) onChanged;

  const DateRangeFilter({
    super.key,
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
