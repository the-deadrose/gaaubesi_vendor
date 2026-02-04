import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/domain/entity/extra_mileage_list_entity.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/presentation/bloc/extra_milage_list_event.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/presentation/bloc/extra_mileage_list_bloc.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/presentation/bloc/extra_mileage_list_state.dart';
import 'package:intl/intl.dart';

@RoutePage()
class ExtraMileageScreen extends StatefulWidget {
  const ExtraMileageScreen({super.key});

  @override
  State<ExtraMileageScreen> createState() => _ExtraMileageScreenState();
}

class _ExtraMileageScreenState extends State<ExtraMileageScreen> {
  final ScrollController _scrollController = ScrollController();
  late ExtraMileageBloc _extraMileageBloc;

  String _selectedStatus = '';
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _extraMileageBloc = context.read<ExtraMileageBloc>();

    _fetchInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchInitialData() {
    _extraMileageBloc.add(
      FetchExtraMileageListEvent(
        status: _selectedStatus,
        startDate: _selectedStartDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedStartDate!)
            : '',
        endDate: _selectedEndDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedEndDate!)
            : '',
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_extraMileageBloc.hasNextPage) {
        _extraMileageBloc.add(const LoadMoreExtraMileageEvent());
      }
    }
  }

  void _refreshData() {
    _extraMileageBloc.add(
      RefreshExtraMileageListEvent(
        status: _selectedStatus,
        startDate: _selectedStartDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedStartDate!)
            : '',
        endDate: _selectedEndDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedEndDate!)
            : '',
      ),
    );
  }

  void _clearDateFilter() {
    setState(() {
      _selectedStartDate = null;
      _selectedEndDate = null;
    });
    _applyFilters();
  }

  void _clearStatusFilter() {
    setState(() {
      _selectedStatus = '';
    });
    _applyFilters();
  }

  void _applyFilters() {
    _fetchInitialData();
  }

  void _showFilterDialog() {
    String tempStatus = _selectedStatus;
    DateTime? tempStartDate = _selectedStartDate;
    DateTime? tempEndDate = _selectedEndDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filters',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha:  0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey.withValues(alpha:  0.2),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFilterSection(
                              title: 'Status',
                              children: [
                                _FilterChip(
                                  label: 'All',
                                  selected: tempStatus == '',
                                  onSelected: (selected) {
                                    setModalState(() => tempStatus = '');
                                  },
                                  icon: Icons.all_inclusive_rounded,
                                ),
                                _FilterChip(
                                  label: 'Pending',
                                  selected: tempStatus == 'pending',
                                  onSelected: (selected) {
                                    setModalState(() => tempStatus = 'pending');
                                  },
                                  icon: Icons.access_time_rounded,
                                  color: Colors.orange,
                                ),
                                _FilterChip(
                                  label: 'Approved',
                                  selected: tempStatus == 'approved',
                                  onSelected: (selected) {
                                    setModalState(() => tempStatus = 'approved');
                                  },
                                  icon: Icons.check_circle_rounded,
                                  color: Colors.green,
                                ),
                                _FilterChip(
                                  label: 'Rejected',
                                  selected: tempStatus == 'rejected',
                                  onSelected: (selected) {
                                    setModalState(() => tempStatus = 'rejected');
                                  },
                                  icon: Icons.cancel_rounded,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildFilterSection(
                              title: 'Date Range',
                              children: [
                                _DatePickerChip(
                                  label: 'Start Date',
                                  date: tempStartDate,
                                  onDatePicked: (date) {
                                    setModalState(() => tempStartDate = date);
                                  },
                                ),
                                const SizedBox(width: 8),
                                _DatePickerChip(
                                  label: 'End Date',
                                  date: tempEndDate,
                                  onDatePicked: (date) {
                                    setModalState(() => tempEndDate = date);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey.withValues(alpha:  0.2),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  tempStatus = '';
                                  tempStartDate = null;
                                  tempEndDate = null;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: Colors.grey.withValues(alpha:  0.3),
                                ),
                              ),
                              child: const Text('Reset All'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedStatus = tempStatus;
                                  _selectedStartDate = tempStartDate;
                                  _selectedEndDate = tempEndDate;
                                });
                                Navigator.pop(context);
                                _applyFilters();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text('Apply Filters'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChips() {
    final chips = <Widget>[];

    if (_selectedStatus.isNotEmpty) {
      chips.add(
        _ActiveFilterChip(
          label: _selectedStatus == 'pending'
              ? 'Pending'
              : _selectedStatus == 'approved'
                  ? 'Approved'
                  : 'Rejected',
          onRemove: _clearStatusFilter,
          color: _getStatusChipColor(_selectedStatus),
          icon: _getStatusIcon(_selectedStatus),
        ),
      );
      chips.add(const SizedBox(width: 8));
    }

    // Date range chip
    if (_selectedStartDate != null || _selectedEndDate != null) {
      chips.add(
        _ActiveFilterChip(
          label: '${_selectedStartDate != null ? DateFormat('dd/MM').format(_selectedStartDate!) : ''}'
              '${_selectedEndDate != null ? ' - ${DateFormat('dd/MM').format(_selectedEndDate!)}' : ''}',
          onRemove: _clearDateFilter,
          icon: Icons.calendar_today_rounded,
        ),
      );
      chips.add(const SizedBox(width: 8));
    }

    if (chips.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.filter_alt_rounded,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              'No filters applied',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: chips),
      ),
    );
  }

  Widget _buildExtraMileageItem(ExtraMileageResponseEntity item) {
    final extraKm = item.extraKm;
    final statusColor = _getExtraKmColor(extraKm);
    final statusLabel = '$extraKm KM';

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${item.order}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                   
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha:  0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getExtraKmIcon(extraKm),
                        size: 12,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoGrid(item),
            const SizedBox(height: 16),
            _buildActionButtons(item),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid(ExtraMileageResponseEntity item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha:  0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.location_on_rounded,
            label: 'Destination',
            value: item.destination,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.pin_drop_rounded,
            label: 'Location',
            value: item.location,
          ),
         
          ],
        
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ExtraMileageResponseEntity item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () {
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: Colors.grey.withValues(alpha:  0.3)),
          ),
          child: const Text('Reject'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text('Approve'),
        ),
      ],
    );
  }

  Color _getExtraKmColor(int extraKm) {
    if (extraKm <= 5) return Colors.green;
    if (extraKm <= 10) return Colors.orange;
    return Colors.red;
  }

  IconData _getExtraKmIcon(int extraKm) {
    if (extraKm <= 5) return Icons.check_circle_rounded;
    if (extraKm <= 10) return Icons.warning_amber_rounded;
    return Icons.error_outline_rounded;
  }

  Color _getStatusChipColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time_rounded;
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.all_inclusive_rounded;
    }
  }


  Widget _buildFilterSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: children,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Extra Mileage'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
       
        actions: [
          _buildAppBarActionButton(
            icon: Icons.filter_list_rounded,
            onPressed: _showFilterDialog,
            tooltip: 'Filters',
          ),
          const SizedBox(width: 8),
          _buildAppBarActionButton(
            icon: Icons.refresh_rounded,
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<ExtraMileageBloc, ExtraMileageListState>(
        listener: (context, state) {
          if (state is ExtraMileageListErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildFilterChips(),
             
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _refreshData();
                    return Future.delayed(const Duration(milliseconds: 300));
                  },
                  color: theme.colorScheme.primary,
                  child: _buildContent(state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBarActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:  0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        padding: EdgeInsets.zero,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildContent(ExtraMileageListState state) {
    if (state is ExtraMileageListLoadingState ) {
      return _buildLoadingState();
    }

    if (state is ExtraMileageListErrorState) {
      return _buildErrorState(state);
    }

    if (state is ExtraMileageListEmptyState) {
      return _buildEmptyState();
    }

    if (state is ExtraMileageListLoadedState ||
        state is ExtraMileageListPaginatedState) {
      final extraMileageList = state is ExtraMileageListLoadedState
          ? state.extraMileageList
          : (state as ExtraMileageListPaginatedState).extraMileageList;

      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
          }
          return false;
        },
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount:
              extraMileageList.results.length +
                  (state is ExtraMileageListPaginatingState ? 1 : 0) +
                  (_extraMileageBloc.hasNextPage ? 1 : 0),
          itemBuilder: (context, index) {
            if (state is ExtraMileageListPaginatingState &&
                index == extraMileageList.results.length) {
              return _buildLoadMoreIndicator();
            }

            if (index == extraMileageList.results.length) {
              if (!_extraMileageBloc.hasNextPage &&
                  extraMileageList.results.isNotEmpty) {
                return _buildEndOfList();
              }
              return const SizedBox.shrink();
            }

            return _buildExtraMileageItem(
              extraMileageList.results[index],
            );
          },
        ),
      );
    }

    if (state is ExtraMileageListInitialState) {
      return _buildInitialState();
    }

    return _buildLoadingState();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading extra mileage requests...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ExtraMileageListErrorState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha:  0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to Load',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _fetchInitialData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha:  0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Extra Mileage',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _selectedStatus.isEmpty
                    ? 'No extra mileage requests found'
                    : 'No $_selectedStatus requests found',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Initializing...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          width: 32,
          height: 32,
          padding: const EdgeInsets.all(8),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEndOfList() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'No more requests to load',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  final IconData icon;
  final Color color;

  const _ActiveFilterChip({
    required this.label,
    required this.onRemove,
    required this.icon,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha:  0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool) onSelected;
  final IconData? icon;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Theme.of(context).colorScheme.primary;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: selected ? chipColor : Colors.grey,
            ),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.grey.withValues(alpha:  0.1),
      selectedColor: chipColor.withValues(alpha:  0.1),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        color: selected ? chipColor : Colors.grey[700],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? chipColor.withValues(alpha:  0.3) : Colors.transparent,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      showCheckmark: false,
    );
  }
}

class _DatePickerChip extends StatelessWidget {
  final String label;
  final DateTime? date;
  final Function(DateTime) onDatePicked;

  const _DatePickerChip({
    required this.label,
    required this.date,
    required this.onDatePicked,
  });

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Colors.white,
                  surface: Theme.of(context).colorScheme.surface,
                  onSurface: Theme.of(context).colorScheme.onSurface,
                ), dialogTheme: DialogThemeData(backgroundColor: Theme.of(context).colorScheme.surface),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          onDatePicked(pickedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: hasDate
              ? Theme.of(context).colorScheme.primary.withValues(alpha:  0.1)
              : Colors.grey.withValues(alpha:  0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasDate
                ? Theme.of(context).colorScheme.primary.withValues(alpha:  0.3)
                : Colors.grey.withValues(alpha:  0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: hasDate
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              hasDate ? DateFormat('dd/MM/yyyy').format(date!) : label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: hasDate ? FontWeight.w600 : FontWeight.normal,
                color: hasDate
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}