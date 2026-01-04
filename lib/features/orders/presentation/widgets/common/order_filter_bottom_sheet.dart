import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/filters/date_range_filter.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/widgets/filters/dropdown_filter.dart';

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

  static const _destinationItems = [
    'Kathmandu',
    'Pokhara',
    'Chitwan',
    'Butwal',
    'Biratnagar',
    'Dharan',
    'Birgunj',
    'Hetauda',
  ];

  @override
  void initState() {
    super.initState();
    _currentConfig = widget.initialConfig;
    _receiverController.text = _currentConfig.receiverSearch ?? '';
    _minChargeController.text = _currentConfig.minCharge?.toString() ?? '';
    _maxChargeController.text = _currentConfig.maxCharge?.toString() ?? '';
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
                color: theme.primaryColor.withValues(alpha:  0.1),
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
          DropdownFilter(
            label: 'Source Branch',
            value: _currentConfig.sourceBranch,
            items: _branchItems,
            onChanged: (value) {
              _updateConfig(
                _currentConfig.copyWith(
                  sourceBranch: value,
                  clearSourceBranch: value == null,
                ),
              );
            },
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 12),
          DropdownFilter(
            label: 'Destination Branch',
            value: _currentConfig.destinationBranch,
            items: _branchItems,
            onChanged: (value) {
              _updateConfig(
                _currentConfig.copyWith(
                  destinationBranch: value,
                  clearDestinationBranch: value == null,
                ),
              );
            },
            icon: Icons.location_on,
          ),
          const SizedBox(height: 24),
        ],

        // Status Filter (only for 'all' type)
        if (widget.filterType == OrderFilterType.all) ...[
          _buildSectionTitle('Order Status', Icons.info_outline),
          const SizedBox(height: 8),
          DropdownFilter(
            label: 'Status',
            value: _currentConfig.status,
            items: _statusItems,
            onChanged: (value) {
              _updateConfig(
                _currentConfig.copyWith(
                  status: value?.toLowerCase().replaceAll(' ', '_'),
                  clearStatus: value == null,
                ),
              );
            },
            icon: Icons.info_outline,
          ),
          const SizedBox(height: 24),
        ],

        // Destination Filter (for delivered, possible redirect, returned, rtv)
        if (widget.filterType != OrderFilterType.all) ...[
          _buildSectionTitle('Destination', Icons.place),
          const SizedBox(height: 8),
          DropdownFilter(
            label: 'Destination',
            value: _currentConfig.destination,
            items: _destinationItems,
            onChanged: (value) {
              _updateConfig(
                _currentConfig.copyWith(
                  destination: value,
                  clearDestination: value == null,
                ),
              );
            },
            icon: Icons.place,
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
            color: Colors.black.withValues(alpha:  0.05),
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
