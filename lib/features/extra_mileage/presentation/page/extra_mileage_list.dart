import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/domain/entity/extra_mileage_list_entity.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/presentation/bloc/extra_milage_list_event.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/presentation/bloc/extra_mileage_list_bloc.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/presentation/bloc/extra_mileage_list_state.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/presentation/bloc/approval/extra_mileage_approval_bloc.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/presentation/bloc/approval/extra_mileage_approval_event.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/presentation/bloc/approval/extra_mileage_approval_state.dart';
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
  late ExtraMileageApprovalBloc _approvalBloc;

  String _selectedStatus = '';
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _extraMileageBloc = context.read<ExtraMileageBloc>();
    _approvalBloc = context.read<ExtraMileageApprovalBloc>();

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

  void _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_selectedStartDate ?? DateTime.now())
          : (_selectedEndDate ?? DateTime.now()),
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
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = pickedDate;
        } else {
          _selectedEndDate = pickedDate;
        }
      });
      _applyFilters();
    }
  }

  Widget _buildStatusChips() {
    const statuses = [
      {'value': '', 'label': 'All', 'icon': Icons.all_inclusive_rounded},
      {
        'value': 'pending',
        'label': 'Pending',
        'icon': Icons.access_time_rounded,
      },
      {
        'value': 'approved',
        'label': 'Approved',
        'icon': Icons.check_circle_rounded,
      },
      {'value': 'rejected', 'label': 'Rejected', 'icon': Icons.cancel_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: statuses.map((status) {
          final isSelected = _selectedStatus == (status['value'] as String?);
          final color = Theme.of(context).colorScheme.primary;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    status['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    status['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = status['value'] as String;
                });
                _applyFilters();
              },
              backgroundColor: color.withValues(alpha: 0.1),
              selectedColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: color.withValues(alpha: isSelected ? 0 : 0.3),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date Range',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDatePickerButton(
                  label: 'Start Date',
                  date: _selectedStartDate,
                  isStartDate: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDatePickerButton(
                  label: 'End Date',
                  date: _selectedEndDate,
                  isStartDate: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedStartDate != null || _selectedEndDate != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _clearDateFilter,
                child: const Text('Clear Date Filter'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDatePickerButton({
    required String label,
    required DateTime? date,
    required bool isStartDate,
  }) {
    return GestureDetector(
      onTap: () => _selectDate(context, isStartDate),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: date != null
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: date != null
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  date != null ? DateFormat('dd/MM/yyyy').format(date) : label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: date != null
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: date != null
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[700],
                  ),
                ),
              ],
            ),
            if (date != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isStartDate) {
                      _selectedStartDate = null;
                    } else {
                      _selectedEndDate = null;
                    }
                  });
                  _applyFilters();
                },
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterChips() {
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
          color: Theme.of(context).colorScheme.primary,
          icon: _getStatusIcon(_selectedStatus),
        ),
      );
    }

    if (_selectedStartDate != null || _selectedEndDate != null) {
      if (chips.isNotEmpty) {
        chips.add(const SizedBox(width: 8));
      }
      chips.add(
        _ActiveFilterChip(
          label:
              '${_selectedStartDate != null ? DateFormat('dd/MM/yy').format(_selectedStartDate!) : ''}'
              '${_selectedEndDate != null ? ' - ${DateFormat('dd/MM/yy').format(_selectedEndDate!)}' : ''}',
          onRemove: _clearDateFilter,
          icon: Icons.calendar_today_rounded,
        ),
      );
    }

    if (chips.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.filter_alt_rounded, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              'No filters applied',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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
      padding: const EdgeInsets.all(16.0),
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                    color: statusColor.withValues(alpha: 0.1),
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
        color: Colors.grey.withValues(alpha: 0.05),
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
        Icon(icon, size: 16, color: Colors.grey[600]),
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
            _showConfirmationDialog(
              title: 'Decline Extra Mileage',
              message:
                  'Are you sure you want to decline this extra mileage request for Order #${item.order}?',
              confirmText: 'Decline',
              onConfirm: () {
                _approvalBloc.add(
                  DeclineExtraMileageRequestEvent(
                    mileageId: item.pk.toString(),
                  ),
                );
                Navigator.pop(context);
              },
            );
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          child: const Text('Reject'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            _showConfirmationDialog(
              title: 'Approve Extra Mileage',
              message:
                  'Are you sure you want to approve this extra mileage request for Order #${item.order}?',
              confirmText: 'Approve',
              onConfirm: () {
                _approvalBloc.add(
                  ApproveExtraMileageRequestEvent(
                    mileageId: item.pk.toString(),
                  ),
                );
                Navigator.pop(context);
              },
            );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return BlocListener<ExtraMileageApprovalBloc, ExtraMileageApprovalState>(
      listener: (context, state) {
        if (state is ExtraMileageApprovedSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          _refreshData();
        } else if (state is ExtraMileageDeclinedSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          _refreshData();
        } else if (state is ExtraMileageApprovalErrorState) {
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
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
        appBar: AppBar(
          title: const Text('Extra Mileage'),
          centerTitle: true,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          actions: [],
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
                _buildStatusChips(),
                _buildDateFilterSection(),
                _buildActiveFilterChips(),
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
      ),
    );
  }

  Widget _buildContent(ExtraMileageListState state) {
    if (state is ExtraMileageListLoadingState ||
        state is ExtraMileageListInitialState) {
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
          if (notification is ScrollEndNotification) {}
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

            return _buildExtraMileageItem(extraMileageList.results[index]);
          },
        ),
      );
    }

    return _buildLoadingState();
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildShimmerItem();
      },
    );
  }

  Widget _buildShimmerItem() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CustomShimmer(
                    width: 120,
                    height: 20,
                    borderRadius: BorderRadius.circular(8),
                    margin: const EdgeInsets.only(bottom: 4),
                  ),
                  _CustomShimmer(
                    width: 80,
                    height: 16,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
              _CustomShimmer(
                width: 60,
                height: 32,
                borderRadius: BorderRadius.circular(16),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Info grid shimmer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildShimmerInfoRow(),
                const SizedBox(height: 12),
                _buildShimmerInfoRow(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _CustomShimmer(
                width: 80,
                height: 40,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 12),
              _CustomShimmer(
                width: 80,
                height: 40,
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerInfoRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CustomShimmer(
          width: 16,
          height: 16,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CustomShimmer(
                width: 60,
                height: 12,
                borderRadius: BorderRadius.circular(6),
                margin: const EdgeInsets.only(bottom: 4),
              ),
              _CustomShimmer(
                width: double.infinity,
                height: 16,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ),
      ],
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
                color: Colors.red.withValues(alpha: 0.1),
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
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _fetchInitialData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
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
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
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
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _selectedStatus.isEmpty
                    ? 'No extra mileage requests found'
                    : 'No $_selectedStatus requests found',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
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

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: _CustomShimmer(
          width: 32,
          height: 32,
          borderRadius: BorderRadius.circular(16),
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
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
      ),
    );
  }
}

class _CustomShimmer extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry margin;

  const _CustomShimmer({
    required this.width,
    required this.height,
    this.borderRadius = BorderRadius.zero,
    this.margin = EdgeInsets.zero,
  });

  @override
  _CustomShimmerState createState() => _CustomShimmerState();
}

class _CustomShimmerState extends State<_CustomShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _gradientPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: false);

    _gradientPosition = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(_gradientPosition.value, 0),
              end: Alignment(1.0, 0.0),
              colors: isDarkMode
                  ? [
                      Colors.grey[800]!.withValues(alpha: 0.1),
                      Colors.grey[700]!.withValues(alpha: 0.2),
                      Colors.grey[600]!.withValues(alpha: 0.3),
                      Colors.grey[700]!.withValues(alpha: 0.2),
                      Colors.grey[800]!.withValues(alpha: 0.1),
                    ]
                  : [
                      Colors.grey[300]!.withValues(alpha: 0.1),
                      Colors.grey[400]!.withValues(alpha: 0.2),
                      Colors.grey[500]!.withValues(alpha: 0.3),
                      Colors.grey[400]!.withValues(alpha: 0.2),
                      Colors.grey[300]!.withValues(alpha: 0.1),
                    ],
              stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
            ),
          ),
        );
      },
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
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
            child: Icon(Icons.close_rounded, size: 14, color: color),
          ),
        ],
      ),
    );
  }
}
