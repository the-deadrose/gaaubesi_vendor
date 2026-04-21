import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_bloc.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_event.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_state.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/destination_branch_bloc.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/destination_branch_state.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/filters/date_range_filter.dart';

/// Filter configuration for bottom sheet
class OrderFilterConfig {
  final String? sourceBranch;
  final String? destinationBranch;
  final String? startDate;
  final String? endDate;
  final String? status;
  final String? destination;
  final String? receiverSearch;
  final double? minCharge;
  final double? maxCharge;

  const OrderFilterConfig({
    this.sourceBranch,
    this.destinationBranch,
    this.startDate,
    this.endDate,
    this.status,
    this.destination,
    this.receiverSearch,
    this.minCharge,
    this.maxCharge,
  });

  OrderFilterConfig copyWith({
    String? sourceBranch,
    String? destinationBranch,
    String? startDate,
    String? endDate,
    String? status,
    String? destination,
    String? receiverSearch,
    double? minCharge,
    double? maxCharge,
    bool clearSourceBranch = false,
    bool clearDestinationBranch = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearStatus = false,
    bool clearDestination = false,
    bool clearReceiverSearch = false,
    bool clearMinCharge = false,
    bool clearMaxCharge = false,
  }) {
    return OrderFilterConfig(
      sourceBranch: clearSourceBranch
          ? null
          : (sourceBranch ?? this.sourceBranch),
      destinationBranch: clearDestinationBranch
          ? null
          : (destinationBranch ?? this.destinationBranch),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      status: clearStatus ? null : (status ?? this.status),
      destination: clearDestination ? null : (destination ?? this.destination),
      receiverSearch: clearReceiverSearch
          ? null
          : (receiverSearch ?? this.receiverSearch),
      minCharge: clearMinCharge ? null : (minCharge ?? this.minCharge),
      maxCharge: clearMaxCharge ? null : (maxCharge ?? this.maxCharge),
    );
  }

  bool get hasActiveFilters =>
      sourceBranch != null ||
      destinationBranch != null ||
      startDate != null ||
      endDate != null ||
      status != null ||
      destination != null ||
      receiverSearch != null ||
      minCharge != null ||
      maxCharge != null;

  int get activeFilterCount {
    int count = 0;
    if (sourceBranch != null) count++;
    if (destinationBranch != null) count++;
    if (startDate != null && endDate != null) count++;
    if (status != null) count++;
    if (destination != null) count++;
    if (receiverSearch != null) count++;
    if (minCharge != null || maxCharge != null) count++;
    return count;
  }
}

/// Type of order filter - different types show different filter options
enum OrderFilterType {
  all, // All orders - full filters
  delivered, // Delivered orders
  possibleRedirect, // Possible redirect orders
  returned, // Returned orders
  rtv, // RTV orders
}

/// Bottom sheet widget for filtering orders
class OrderFilterBottomSheet extends StatefulWidget {
  final OrderFilterConfig initialConfig;
  final OrderFilterType filterType;
  final Function(OrderFilterConfig) onApply;

  const OrderFilterBottomSheet({
    super.key,
    required this.initialConfig,
    required this.filterType,
    required this.onApply,
  });

  @override
  State<OrderFilterBottomSheet> createState() => _OrderFilterBottomSheetState();

  /// Show the bottom sheet and return the selected filter config
  static Future<OrderFilterConfig?> show({
    required BuildContext context,
    required OrderFilterConfig initialConfig,
    required OrderFilterType filterType,
  }) {
    return showModalBottomSheet<OrderFilterConfig>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderFilterBottomSheet(
        initialConfig: initialConfig,
        filterType: filterType,
        onApply: (config) => Navigator.pop(context, config),
      ),
    );
  }
}

class _OrderFilterBottomSheetState extends State<OrderFilterBottomSheet> {
  late OrderFilterConfig _currentConfig;
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _minChargeController = TextEditingController();
  final TextEditingController _maxChargeController = TextEditingController();

  static const Map<String, String> _statusLabelByValue = {
    'dropoff_order_created': 'Drop-off Order',
    'pickup_order_created': 'Pickup Order',
    'send_for_pickup': 'Send for Pickup',
    'pickup_complete': 'Pickup Complete',
    'dispatched': 'Dispatch',
    'arrived':'Arrived',
    'send_for_delivery': 'Out for Delivery',
    'delivered': 'Delivered',
    'return_deliverd': 'Return Delivered',
    'send_to_vendor': 'Send to Vendor',
    'order_created': 'Order Created',
    'hold': 'Hold',
    'cancelled': 'Cancelled',
    'rtv_branch': 'RTV Branch',
    'rtv_all': 'RTV All',
  };

  @override
  void initState() {
    super.initState();
    _currentConfig = widget.initialConfig;
    _receiverController.text = _currentConfig.receiverSearch ?? '';
    _minChargeController.text = _currentConfig.minCharge?.toString() ?? '';
    _maxChargeController.text = _currentConfig.maxCharge?.toString() ?? '';
    _loadBranchFilters();
  }

  void _loadBranchFilters() {
    final branchBloc = context.read<BranchListBloc>();
    if (branchBloc.state is! BranchListLoaded) {
      branchBloc.add(const FetchBranchListEvent(''));
    }

    final destinationBranchBloc = context.read<DestinationBranchBloc>();
    if (destinationBranchBloc.state is! DestinationBranchLoaded) {
      destinationBranchBloc.add(const FetchDestinationBranchEvent(''));
    }
  }

  List<String> _extractBranchLabels(List<dynamic> branches) {
    final seen = <String>{};
    return branches
        .map((branch) => (branch.label as String).trim())
        .where((label) => label.isNotEmpty)
        .where((label) => seen.add(label))
        .toList();
  }

  String? _statusLabelFromValue(String? value) {
    if (value == null || value.isEmpty) return null;
    return _statusLabelByValue[value];
  }

  String? _statusValueFromLabel(String? label) {
    if (label == null || label.isEmpty) return null;
    for (final entry in _statusLabelByValue.entries) {
      if (entry.value == label) return entry.key;
    }
    return null;
  }

  Widget _buildSearchableDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
    required bool isDark,
    String searchHint = 'Search...',
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () async {
        FocusScope.of(context).unfocus();
        final selected = await showDialog<String?>(
          context: context,
          builder: (dialogContext) => _SearchableOptionsDialog(
            title: label,
            options: items,
            selectedValue: value,
            searchHint: searchHint,
          ),
        );

        if (!mounted) return;
        onChanged(selected);
      },
      child: AbsorbPointer(
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, size: 18),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            filled: true,
            fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          child: Text(
            value ?? 'All $label',
            style: TextStyle(
              color: value == null
                  ? (isDark ? Colors.grey[400] : Colors.grey[600])
                  : (isDark ? Colors.white : Colors.black87),
              fontSize: 13,
              fontWeight: value == null ? FontWeight.w400 : FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _receiverController.dispose();
    _minChargeController.dispose();
    _maxChargeController.dispose();
    super.dispose();
  }

  void _updateConfig(OrderFilterConfig newConfig) {
    setState(() {
      _currentConfig = newConfig;
    });
  }

  void _resetFilters() {
    setState(() {
      _currentConfig = const OrderFilterConfig();
      _receiverController.clear();
      _minChargeController.clear();
      _maxChargeController.clear();
    });
  }

  void _applyFilters() {
    // Parse charge values
    double? minCharge;
    double? maxCharge;
    if (_minChargeController.text.isNotEmpty) {
      minCharge = double.tryParse(_minChargeController.text);
    }
    if (_maxChargeController.text.isNotEmpty) {
      maxCharge = double.tryParse(_maxChargeController.text);
    }

    final finalConfig = _currentConfig.copyWith(
      receiverSearch: _receiverController.text.isEmpty
          ? null
          : _receiverController.text,
      minCharge: minCharge,
      maxCharge: maxCharge,
      clearReceiverSearch: _receiverController.text.isEmpty,
      clearMinCharge: minCharge == null,
      clearMaxCharge: maxCharge == null,
    );

    widget.onApply(finalConfig);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              _buildHeader(theme, isDark),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: mediaQuery.viewInsets.bottom + 16,
                  ),
                  children: [_buildFilterContent(theme, isDark)],
                ),
              ),
              _buildActionButtons(theme, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, color: theme.primaryColor, size: 24),
          const SizedBox(width: 12),
          Text(
            'Filter Orders',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (_currentConfig.hasActiveFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentConfig.activeFilterCount} active',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContent(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Date Range Filter (all types)
        _buildSectionTitle('Date Range', Icons.date_range),
        const SizedBox(height: 8),
        DateRangeFilter(
          startDate: _currentConfig.startDate,
          endDate: _currentConfig.endDate,
          onChanged: (start, end) {
            _updateConfig(
              _currentConfig.copyWith(
                startDate: start,
                endDate: end,
                clearStartDate: start == null,
                clearEndDate: end == null,
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        // Branch Filters (only for 'all' type)
        if (widget.filterType == OrderFilterType.all) ...[
          _buildSectionTitle('Branch Filters', Icons.account_tree),
          const SizedBox(height: 8),
          BlocBuilder<BranchListBloc, BranchListState>(
            builder: (context, branchState) {
              final sourceBranchItems = branchState is BranchListLoaded
                  ? _extractBranchLabels(branchState.branchList)
                  : <String>[];

              return _buildSearchableDropdown(
                label: 'Source Branch',
                value: _currentConfig.sourceBranch,
                items: sourceBranchItems,
                onChanged: (value) {
                  _updateConfig(
                    _currentConfig.copyWith(
                      sourceBranch: value,
                      clearSourceBranch: value == null,
                    ),
                  );
                },
                icon: Icons.location_on_outlined,
                isDark: isDark,
                searchHint: 'Search source branch...',
              );
            },
          ),
          const SizedBox(height: 12),
          BlocBuilder<DestinationBranchBloc, DestinationBranchState>(
            builder: (context, destinationBranchState) {
              final destinationBranchItems =
                  destinationBranchState is DestinationBranchLoaded
                  ? _extractBranchLabels(
                      destinationBranchState.destinationBranch,
                    )
                  : <String>[];

              return _buildSearchableDropdown(
                label: 'Destination Branch',
                value: _currentConfig.destinationBranch,
                items: destinationBranchItems,
                onChanged: (value) {
                  _updateConfig(
                    _currentConfig.copyWith(
                      destinationBranch: value,
                      clearDestinationBranch: value == null,
                    ),
                  );
                },
                icon: Icons.location_on,
                isDark: isDark,
                searchHint: 'Search destination branch...',
              );
            },
          ),
          const SizedBox(height: 24),
        ],

        // Status Filter (only for 'all' type)
        if (widget.filterType == OrderFilterType.all) ...[
          _buildSectionTitle('Order Status', Icons.info_outline),
          const SizedBox(height: 8),
          _buildSearchableDropdown(
            label: 'Status',
            value: _statusLabelFromValue(_currentConfig.status),
            items: _statusLabelByValue.values.toList(),
            onChanged: (value) {
              _updateConfig(
                _currentConfig.copyWith(
                  status: _statusValueFromLabel(value),
                  clearStatus: value == null,
                ),
              );
            },
            icon: Icons.info_outline,
            isDark: isDark,
            searchHint: 'Search status...',
          ),
          const SizedBox(height: 24),
        ],

        // Destination Filter (for delivered, possible redirect, returned, rtv)
        if (widget.filterType != OrderFilterType.all) ...[
          _buildSectionTitle('Destination', Icons.place),
          const SizedBox(height: 8),
          BlocBuilder<DestinationBranchBloc, DestinationBranchState>(
            builder: (context, destinationBranchState) {
              final destinationItems =
                  destinationBranchState is DestinationBranchLoaded
                  ? _extractBranchLabels(
                      destinationBranchState.destinationBranch,
                    )
                  : <String>[];

              return _buildSearchableDropdown(
                label: 'Destination',
                value: _currentConfig.destination,
                items: destinationItems,
                onChanged: (value) {
                  _updateConfig(
                    _currentConfig.copyWith(
                      destination: value,
                      clearDestination: value == null,
                    ),
                  );
                },
                icon: Icons.place,
                isDark: isDark,
                searchHint: 'Search destination...',
              );
            },
          ),
          const SizedBox(height: 24),
        ],

        // Receiver Search (for all types)
        _buildSectionTitle('Receiver Information', Icons.person_search),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _receiverController,
          label: 'Search by Receiver Name/Number',
          icon: Icons.person,
          isDark: isDark,
        ),
        const SizedBox(height: 24),

        // Charge Range (for all types)
        _buildSectionTitle('Charge Range', Icons.money),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _minChargeController,
                label: 'Min Charge',
                icon: Icons.attach_money,
                isDark: isDark,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _maxChargeController,
                label: 'Max Charge',
                icon: Icons.attach_money,
                isDark: isDark,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 13,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  controller.clear();
                  setState(() {});
                },
              )
            : null,
        filled: true,
        fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildActionButtons(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Reset Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _currentConfig.hasActiveFilters ? _resetFilters : null,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reset'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: _currentConfig.hasActiveFilters
                      ? theme.primaryColor
                      : Colors.grey[400]!,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Apply Button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _applyFilters,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Apply Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchableOptionsDialog extends StatefulWidget {
  final String title;
  final List<String> options;
  final String? selectedValue;
  final String searchHint;

  const _SearchableOptionsDialog({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.searchHint,
  });

  @override
  State<_SearchableOptionsDialog> createState() =>
      _SearchableOptionsDialogState();
}

class _SearchableOptionsDialogState extends State<_SearchableOptionsDialog> {
  final TextEditingController _searchController = TextEditingController();
  late List<String> _filteredOptions;

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredOptions = widget.options;
        return;
      }
      final q = query.toLowerCase().trim();
      _filteredOptions = widget.options
          .where((option) => option.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 560, maxWidth: 480),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filter('');
                          },
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                onChanged: _filter,
              ),
            ),
            const Divider(height: 1),
            ListTile(
              title: Text('All ${widget.title}'),
              trailing: widget.selectedValue == null
                  ? Icon(Icons.check_circle, color: theme.primaryColor)
                  : null,
              onTap: () => Navigator.pop(context, null),
            ),
            const Divider(height: 1),
            Expanded(
              child: _filteredOptions.isEmpty
                  ? Center(
                      child: Text(
                        'No results found',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredOptions.length,
                      itemBuilder: (context, index) {
                        final option = _filteredOptions[index];
                        final isSelected = option == widget.selectedValue;

                        return ListTile(
                          title: Text(option),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: theme.primaryColor,
                                )
                              : null,
                          selected: isSelected,
                          selectedTileColor: theme.primaryColor.withValues(
                            alpha: 0.08,
                          ),
                          onTap: () => Navigator.pop(context, option),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
