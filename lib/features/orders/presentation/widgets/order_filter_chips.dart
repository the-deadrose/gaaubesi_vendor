import 'package:flutter/material.dart';

/// Filter chips for quick order filtering
class OrderFilterChips extends StatelessWidget {
  final List<OrderFilter> filters;
  final Set<String> selectedFilters;
  final Function(String) onFilterToggled;
  final VoidCallback? onClearAll;

  const OrderFilterChips({
    super.key,
    required this.filters,
    required this.selectedFilters,
    required this.onFilterToggled,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ...filters.map(
            (filter) => _FilterChip(
              filter: filter,
              isSelected: selectedFilters.contains(filter.id),
              onTap: () => onFilterToggled(filter.id),
            ),
          ),
          if (selectedFilters.isNotEmpty && onClearAll != null) ...[
            const SizedBox(width: 8),
            _ClearAllChip(onTap: onClearAll!),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final OrderFilter filter;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.filter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: FilterChip(
          selected: isSelected,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (filter.icon != null) ...[
                Icon(
                  filter.icon,
                  size: 16,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
              ],
              Text(filter.label),
              if (filter.count != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(
                            context,
                          ).colorScheme.onPrimary.withOpacity(0.2)
                        : Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    filter.count.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          onSelected: (_) => onTap(),
          selectedColor: Theme.of(context).colorScheme.primary,
          checkmarkColor: Theme.of(context).colorScheme.onPrimary,
          labelStyle: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.primary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          elevation: isSelected ? 2 : 0,
          pressElevation: 4,
        ),
      ),
    );
  }
}

class _ClearAllChip extends StatelessWidget {
  final VoidCallback onTap;

  const _ClearAllChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.clear_all, size: 16),
          SizedBox(width: 4),
          Text('Clear All'),
        ],
      ),
      onPressed: onTap,
      backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.1),
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.error,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
    );
  }
}

/// Model for order filter
class OrderFilter {
  final String id;
  final String label;
  final IconData? icon;
  final int? count;

  const OrderFilter({
    required this.id,
    required this.label,
    this.icon,
    this.count,
  });
}
