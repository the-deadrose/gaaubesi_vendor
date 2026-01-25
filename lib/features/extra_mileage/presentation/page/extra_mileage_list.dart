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

  // Filter variables
  String _selectedStatus = 'pending';
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _extraMileageBloc = context.read<ExtraMileageBloc>();

    // Initial fetch with default filters
    _fetchInitialData();

    // Setup scroll listener for pagination
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

  void _applyFilters() {
    _fetchInitialData();
  }

  void _showFilterDialog() {
    String tempStatus = _selectedStatus;
    DateTime? tempStartDate = _selectedStartDate;
    DateTime? tempEndDate = _selectedEndDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Extra Mileage'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Status:'),
              DropdownButtonFormField<String>(
                initialValue: tempStatus,
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'approved', child: Text('Approved')),
                  DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                  DropdownMenuItem(value: '', child: Text('All')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    tempStatus = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text('Start Date:'),
              ListTile(
                title: Text(
                  tempStartDate != null
                      ? DateFormat('dd-MM-yyyy').format(tempStartDate!)
                      : 'Select start date',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: tempStartDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    tempStartDate = pickedDate;
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
              const SizedBox(height: 8),
              const Text('End Date:'),
              ListTile(
                title: Text(
                  tempEndDate != null
                      ? DateFormat('dd-MM-yyyy').format(tempEndDate!)
                      : 'Select end date',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: tempEndDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    tempEndDate = pickedDate;
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedStatus = tempStatus;
                  _selectedStartDate = tempStartDate;
                  _selectedEndDate = tempEndDate;
                });
                Navigator.pop(context);
                _applyFilters();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChips() {
    final chips = <Widget>[];

    chips.add(
      InputChip(
        label: Text(
          _selectedStatus.isNotEmpty
              ? 'Status: ${_selectedStatus.replaceAll('_', ' ')}'
              : 'Status: All',
        ),
        onPressed: () => _showFilterDialog(),
        deleteIcon: const Icon(Icons.edit, size: 16),
        onDeleted: () {
          setState(() {
            _selectedStatus = 'pending';
          });
          _applyFilters();
        },
      ),
    );

    if (_selectedStartDate != null || _selectedEndDate != null) {
      chips.add(const SizedBox(width: 8));
      chips.add(
        InputChip(
          label: Text(
            '${_selectedStartDate != null ? DateFormat('dd/MM').format(_selectedStartDate!) : ''}'
            '${_selectedEndDate != null ? ' - ${DateFormat('dd/MM').format(_selectedEndDate!)}' : ''}',
          ),
          onDeleted: _clearDateFilter,
          deleteIcon: const Icon(Icons.close, size: 16),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: chips),
    );
  }

  Widget _buildExtraMileageItem(ExtraMileageResponseEntity item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${item.order}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item.extraKm),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${item.extraKm} KM',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Destination', item.destination),
            _buildInfoRow('Location', item.location),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (item.extraKm > 0)
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle approve action
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    // Handle reject action
                  },
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(int extraKm) {
    if (extraKm <= 5) return Colors.green;
    if (extraKm <= 10) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extra Mileage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: BlocConsumer<ExtraMileageBloc, ExtraMileageListState>(
        listener: (context, state) {
          if (state is ExtraMileageListErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
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
                  },
                  child: _buildContent(state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(ExtraMileageListState state) {
    if (state is ExtraMileageListLoadingState) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ExtraMileageListErrorState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchInitialData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is ExtraMileageListEmptyState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.list_alt, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No extra mileage requests found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedStatus.isEmpty ? 'Try changing filters' : '',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchInitialData,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    if (state is ExtraMileageListLoadedState ||
        state is ExtraMileageListPaginatedState) {
      final extraMileageList = state is ExtraMileageListLoadedState
          ? state.extraMileageList
          : (state as ExtraMileageListPaginatedState).extraMileageList;

      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            // Handle any post-scroll logic if needed
          }
          return false;
        },
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount:
              extraMileageList.results.length +
              (state is ExtraMileageListPaginatingState ? 1 : 0) +
              (_extraMileageBloc.hasNextPage ? 1 : 0),
          itemBuilder: (context, index) {
            if (state is ExtraMileageListPaginatingState &&
                index == extraMileageList.results.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (index == extraMileageList.results.length) {
              if (!_extraMileageBloc.hasNextPage &&
                  extraMileageList.results.isNotEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'No more requests to load',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }

            return _buildExtraMileageItem(
              extraMileageList.results[index],
              index,
            );
          },
        ),
      );
    }

    if (state is ExtraMileageListInitialState) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading extra mileage requests...'),
          ],
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }
}

class DateFormatter {
  static String formatDate(DateTime date, {String format = 'dd-MM-yyyy'}) {
    return DateFormat(format).format(date);
  }

  static String formatApiDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static DateTime? parseDate(
    String dateString, {
    String format = 'yyyy-MM-dd',
  }) {
    try {
      return DateFormat(format).parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
