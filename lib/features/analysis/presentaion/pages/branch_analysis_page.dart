import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/theme/theme.dart';
import 'package:gaaubesi_vendor/features/analysis/domain/entity/branch_report_analysis_entity.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/branch/branch_report_analysis_bloc.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/branch/branch_report_analysis_event.dart';
import 'package:gaaubesi_vendor/features/analysis/presentaion/bloc/branch/branch_report_analysis_state.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/branch_list_entity.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_bloc.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_event.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/branch/branch_list_state.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

@RoutePage()
class BranchReportAnalysisScreen extends StatefulWidget {
  const BranchReportAnalysisScreen({super.key});

  @override
  State<BranchReportAnalysisScreen> createState() =>
      _BranchReportAnalysisScreenState();
}

class _BranchReportAnalysisScreenState
    extends State<BranchReportAnalysisScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  OrderStatusEntity? _selectedBranch;
  static const int maxDaysRange = 180;
  String? _dateRangeError;
  bool _isSearching = false;
  final FocusNode _searchFocusNode = FocusNode();
  List<OrderStatusEntity> _filteredBranches = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedEndDate = now;
    _selectedStartDate = now.subtract(const Duration(days: 30));
    _startDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedStartDate!);
    _endDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedEndDate!);

    context.read<BranchListBloc>().add(const FetchBranchListEvent(''));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAnalysis();
    });
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  bool _validateDateRange(DateTime startDate, DateTime endDate) {
    final difference = endDate.difference(startDate).inDays;
    if (difference > maxDaysRange) {
      setState(() {
        _dateRangeError =
            'Date range cannot exceed $maxDaysRange days (6 months). Current range: ${difference + 1} days';
      });
      return false;
    } else {
      setState(() {
        _dateRangeError = null;
      });
      return true;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _selectedStartDate : _selectedEndDate;
    final now = DateTime.now();

    late DateTime firstDate;
    late DateTime lastDate;

    if (isStartDate) {
      firstDate = now.subtract(const Duration(days: 365));
      lastDate = _selectedEndDate ?? now;
    } else {
      firstDate = _selectedStartDate ?? now.subtract(const Duration(days: 365));
      lastDate = now;
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      if (isStartDate) {
        if (_selectedEndDate != null) {
          if (!_validateDateRange(pickedDate, _selectedEndDate!)) {
            return;
          }
        }
        _selectedStartDate = pickedDate;
        _startDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      } else {
        if (_selectedStartDate != null) {
          if (!_validateDateRange(_selectedStartDate!, pickedDate)) {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_dateRangeError ?? 'Invalid date range'),
                backgroundColor: AppTheme.rojo,
              ),
            );
            return;
          }
        }
        _selectedEndDate = pickedDate;
        _endDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      }
      _fetchAnalysis();
    }
  }

  void _fetchAnalysis() {
    if (_selectedStartDate != null && _selectedEndDate != null) {
      if (!_validateDateRange(_selectedStartDate!, _selectedEndDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_dateRangeError ?? 'Invalid date range'),
            backgroundColor: AppTheme.rojo,
          ),
        );
        return;
      }

      final branchName = _selectedBranch != null
          ? _selectedBranch!.label
          : (_searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim());

      context.read<BranchReportAnalysisBloc>().add(
            FetchBranchReportAnalysisEvent(
              startDate: _startDateController.text,
              endDate: _endDateController.text,
              branchName: branchName,
            ),
          );
    }
  }

  void _resetFilters() {
    final now = DateTime.now();
    _selectedStartDate = now.subtract(const Duration(days: 30));
    _selectedEndDate = now;
    _selectedBranch = null;
    _searchController.clear();

    _startDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedStartDate!);
    _endDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedEndDate!);

    setState(() {
      _dateRangeError = null;
      _isSearching = false;
    });

    _fetchAnalysis();
  }

  void _selectBranch(OrderStatusEntity branch) {
    setState(() {
      _selectedBranch = branch;
      _searchController.text = branch.label;
    });
    _fetchAnalysis();
  }

  void _clearBranchSelection() {
    setState(() {
      _selectedBranch = null;
      _searchController.clear();
    });
    _fetchAnalysis();
  }

  void _clearSearch() {
    setState(() {
      _selectedBranch = null;
      _searchController.clear();
      _isSearching = false;
    });
    _fetchAnalysis();
  }

  void _searchBranches(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBranches = [];
      } else {
        final state = context.read<BranchListBloc>().state;
        if (state is BranchListLoaded) {
          _filteredBranches = state.branchList
              .where((branch) =>
                  branch.label.toLowerCase().contains(query.toLowerCase()) ||
                  branch.code.toLowerCase().contains(query.toLowerCase()) ||
                  branch.value.contains(query))
              .toList();
        }
      }
    });
  }

  void _showBranchSearchDialog(List<OrderStatusEntity> branches) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Branch'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (query) {
                    setState(() {
                      if (query.isEmpty) {
                        _filteredBranches = branches;
                      } else {
                        _filteredBranches = branches
                            .where(
                              (branch) =>
                                  branch.label.toLowerCase().contains(
                                    query.toLowerCase(),
                                  ) ||
                                  branch.code.toLowerCase().contains(
                                    query.toLowerCase(),
                                  ) ||
                                  branch.value.contains(query),
                            )
                            .toList();
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name, code or ID...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: (branches.isEmpty && _filteredBranches.isEmpty)
                      ? const Center(child: Text('No branches available'))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredBranches.isNotEmpty
                              ? _filteredBranches.length
                              : branches.length,
                          itemBuilder: (context, index) {
                            final branch = _filteredBranches.isNotEmpty
                                ? _filteredBranches[index]
                                : branches[index];
                            final isSelected =
                                _selectedBranch?.value == branch.value;
                            return ListTile(
                              selected: isSelected,
                              selectedTileColor:
                                  AppTheme.marianBlue.withValues(alpha: 0.1),
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppTheme.marianBlue.withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.store,
                                  size: 20,
                                  color: AppTheme.marianBlue,
                                ),
                              ),
                              title: Text(
                                branch.label,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                '${branch.code} (ID: ${branch.value})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.darkGray,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check,
                                      color: AppTheme.marianBlue,
                                    )
                                  : null,
                              onTap: () {
                                Navigator.pop(context);
                                _selectBranch(branch);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.marianBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search by branch name or ID...',
        border: InputBorder.none,
        hintStyle:
            TextStyle(color: AppTheme.whiteSmoke.withValues(alpha: 0.7)),
      ),
      style: TextStyle(color: AppTheme.whiteSmoke, fontSize: 16),
      onChanged: _searchBranches,
      onSubmitted: (_) {
        setState(() {
          _isSearching = false;
        });
        _fetchAnalysis();
      },
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: Icon(Icons.clear, color: AppTheme.whiteSmoke),
          onPressed: _clearSearch,
        ),
      ];
    } else {
      return [
        IconButton(
          icon: Icon(Icons.search, color: AppTheme.whiteSmoke),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _searchFocusNode.requestFocus();
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: AppTheme.whiteSmoke),
          onPressed: _resetFilters,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteSmoke,
      appBar: AppBar(
        backgroundColor: AppTheme.marianBlue,
        foregroundColor: AppTheme.whiteSmoke,
        title: _isSearching
            ? _buildSearchField()
            : const Text('Branch Report Analysis'),
        centerTitle: !_isSearching,
        actions: _buildAppBarActions(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDateFilterSection(),
            const SizedBox(height: 8),

            BlocBuilder<BranchReportAnalysisBloc, BranchReportAnalysisState>(
              builder: (context, state) {
                if (state is BranchReportAnalysisLoadedState) {
                  return _buildStatsCards(state.branchReports);
                } else if (state is BranchReportAnalysisSearchResultState) {
                  return _buildStatsCards(state.searchResults);
                }
                return const SizedBox.shrink();
              },
            ),

            BlocBuilder<BranchReportAnalysisBloc, BranchReportAnalysisState>(
              builder: (context, state) {
                return _buildContentBasedOnState(state);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.filter_alt,
                size: 20,
                color: AppTheme.marianBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'Filter Analysis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.blackBean,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.powerBlue, width: 1),
                ),
                child: Text(
                  'Max: 6 months',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_dateRangeError != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.rojo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.rojo.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppTheme.rojo, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _dateRangeError!,
                      style: TextStyle(color: AppTheme.rojo, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          BlocBuilder<BranchListBloc, BranchListState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Branch (Optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (state is BranchListLoaded) ...[
                    _buildBranchSelectionField(state.branchList),
                  ] else if (state is BranchListLoading) ...[
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.powerBlue.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.marianBlue,
                          ),
                        ),
                      ),
                    ),
                  ] else if (state is BranchListError) ...[
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.rojo.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: AppTheme.rojo.withValues(alpha: 0.05),
                      ),
                      child: Center(
                        child: Text(
                          'Error loading branches',
                          style: TextStyle(
                            color: AppTheme.rojo,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
              );
            },
          ),

          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  controller: _startDateController,
                  label: 'Start Date',
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateField(
                  controller: _endDateController,
                  label: 'End Date',
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: _fetchAnalysis,
            icon: const Icon(Icons.analytics, size: 20),
            label: const Text('Analyze Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.marianBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchSelectionField(List<OrderStatusEntity> branches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.powerBlue.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Icon(
                Icons.store,
                size: 18,
                color: _selectedBranch != null
                    ? AppTheme.successGreen
                    : AppTheme.darkGray,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _selectedBranch != null
                    ? Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _selectedBranch!.label,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${_selectedBranch!.code} • ID: ${_selectedBranch!.value}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.darkGray,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 18,
                              color: AppTheme.darkGray,
                            ),
                            onPressed: _clearBranchSelection,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      )
                    : InkWell(
                        onTap: () => _showBranchSearchDialog(branches),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'All branches',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.darkGray,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: AppTheme.darkGray,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
        if (branches.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${branches.length} branches available',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.darkGray,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.powerBlue.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: AppTheme.marianBlue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.text,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: AppTheme.darkGray),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(List<BranchReportAnalysisEntity> reports) {
    if (reports.isEmpty) return const SizedBox();

    final totalOrders = reports.fold(0, (sum, report) => sum + report.total);
    final totalProcessing = reports.fold(
      0,
      (sum, report) => sum + report.processingOrders,
    );
    final totalDelivered = reports.fold(
      0,
      (sum, report) => sum + report.delivered,
    );
    final totalReturned = reports.fold(
      0,
      (sum, report) => sum + report.returned,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              value: totalOrders.toString(),
              label: 'Total Orders',
              icon: Icons.shopping_bag,
              color: AppTheme.infoBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              value: totalProcessing.toString(),
              label: 'Processing',
              icon: Icons.sync,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              value: totalDelivered.toString(),
              label: 'Delivered',
              icon: Icons.check_circle,
              color: AppTheme.successGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              value: totalReturned.toString(),
              label: 'Returned',
              icon: Icons.reply,
              color: AppTheme.rojo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: AppTheme.darkGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContentBasedOnState(BranchReportAnalysisState state) {
    if (state is BranchReportAnalysisInitialState) {
      return _buildInitialView();
    } else if (state is BranchReportAnalysisLoadingState) {
      return _buildShimmerLoading();
    } else if (state is BranchReportAnalysisLoadedState) {
      return _buildAnalysisView(state.branchReports);
    } else if (state is BranchReportAnalysisSearchResultState) {
      return _buildAnalysisView(state.searchResults);
    } else if (state is BranchReportAnalysisEmptyState) {
      return _buildEmptyView();
    } else if (state is BranchReportAnalysisErrorState) {
      return _buildErrorView(state.message);
    }
    return Container();
  }

  Widget _buildInitialView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: AppTheme.powerBlue.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Select filters and click "Analyze Data"',
              style: TextStyle(fontSize: 16, color: AppTheme.darkGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildShimmerCard();
      },
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 16,
            width: 200,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 150,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisView(List<BranchReportAnalysisEntity> reports) {
    if (reports.isEmpty) return _buildEmptyView();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryChart(reports),
        const SizedBox(height: 24),

        _buildBranchDetailsSection(reports),
      ],
    );
  }

  Widget _buildSummaryChart(List<BranchReportAnalysisEntity> reports) {
    if (reports.length > 10) {
      return _buildTopBranchesChart(reports);
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, size: 20, color: AppTheme.marianBlue),
              const SizedBox(width: 8),
              Text(
                'Branch Performance Comparison',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.blackBean,
                ),
              ),
              const Spacer(),
              Chip(
                label: Text('${reports.length} branches'),
                backgroundColor: AppTheme.lightGray,
                labelStyle: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_startDateController.text} to ${_endDateController.text}',
            style: TextStyle(fontSize: 12, color: AppTheme.darkGray),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                labelRotation: -45,
                labelStyle: const TextStyle(fontSize: 10),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(
                  text: 'Number of Orders',
                  textStyle: const TextStyle(fontSize: 12),
                ),
                majorGridLines: const MajorGridLines(
                  color: Color(0xffeeeeee),
                  width: 1,
                ),
                axisLine: const AxisLine(width: 0),
              ),
              series: <ColumnSeries<BranchReportAnalysisEntity, String>>[
                ColumnSeries<BranchReportAnalysisEntity, String>(
                  dataSource: reports,
                  xValueMapper: (data, _) => data.name.length > 10
                      ? '${data.name.substring(0, 10)}...'
                      : data.name,
                  yValueMapper: (data, _) => data.total,
                  name: 'Total Orders',
                  color: AppTheme.marianBlue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  width: 0.6,
                ),
              ],
              tooltipBehavior: TooltipBehavior(
                enable: true,
                format: 'point.x\nOrders: point.y',
                header: '',
                canShowMarker: false,
                color: Colors.white,
                textStyle: const TextStyle(color: Colors.black, fontSize: 12),
                borderColor: AppTheme.marianBlue,
                borderWidth: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBranchesChart(List<BranchReportAnalysisEntity> reports) {
    final topBranches = reports
      ..sort((a, b) => b.total.compareTo(a.total))
      ..take(10);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.leaderboard, size: 20, color: AppTheme.marianBlue),
              const SizedBox(width: 8),
              Text(
                'Top 10 Branches by Order Volume',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.blackBean,
                ),
              ),
              const Spacer(),
              Chip(
                label: Text('Top 10 of ${reports.length}'),
                backgroundColor: AppTheme.lightGray,
                labelStyle: const TextStyle(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_startDateController.text} to ${_endDateController.text}',
            style: TextStyle(fontSize: 12, color: AppTheme.darkGray),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                labelRotation: -45,
                labelStyle: const TextStyle(fontSize: 10),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(
                  text: 'Number of Orders',
                  textStyle: const TextStyle(fontSize: 12),
                ),
                majorGridLines: const MajorGridLines(
                  color: Color(0xffeeeeee),
                  width: 1,
                ),
                axisLine: const AxisLine(width: 0),
              ),
              series: <ColumnSeries<BranchReportAnalysisEntity, String>>[
                ColumnSeries<BranchReportAnalysisEntity, String>(
                  dataSource: topBranches.toList(),
                  xValueMapper: (data, _) => data.name.length > 8
                      ? '${data.name.substring(0, 8)}...'
                      : data.name,
                  yValueMapper: (data, _) => data.total,
                  name: 'Total Orders',
                  color: AppTheme.marianBlue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  width: 0.6,
                ),
              ],
              tooltipBehavior: TooltipBehavior(
                enable: true,
                format: 'point.x\nOrders: point.y',
                header: '',
                canShowMarker: false,
                color: Colors.white,
                textStyle: const TextStyle(color: Colors.black, fontSize: 12),
                borderColor: AppTheme.marianBlue,
                borderWidth: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchDetailsSection(List<BranchReportAnalysisEntity> reports) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.list_alt, size: 20, color: AppTheme.marianBlue),
              const SizedBox(width: 8),
              Text(
                'Branch Performance Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.blackBean,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${reports.length} branches',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...reports.map((branch) {
            return _buildBranchItem(branch);
          }),
        ],
      ),
    );
  }

  Widget _buildBranchItem(BranchReportAnalysisEntity branch) {
    final total = branch.total;
    final processingPercent = total > 0
        ? (branch.processingOrders / total * 100).toStringAsFixed(1)
        : '0.0';
    final deliveredPercent = total > 0
        ? (branch.delivered / total * 100).toStringAsFixed(1)
        : '0.0';
    final returnedPercent = total > 0
        ? (branch.returned / total * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppTheme.powerBlue.withValues(alpha: 0.1)),
        ),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.marianBlue.withValues(alpha: 0.1),
            child: Text(
              branch.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: AppTheme.marianBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            branch.name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            'ID: ${branch.destinationBranch}',
            style: TextStyle(fontSize: 11, color: AppTheme.darkGray),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: total > 0
                  ? AppTheme.successGreen.withValues(alpha: 0.1)
                  : AppTheme.lightGray,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: total > 0
                    ? AppTheme.successGreen.withValues(alpha: 0.3)
                    : AppTheme.darkGray.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              '$total',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: total > 0 ? AppTheme.successGreen : AppTheme.darkGray,
              ),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildBranchStatRow(
                    'Processing',
                    branch.processingOrders,
                    '$processingPercent%',
                    Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  _buildBranchStatRow(
                    'Delivered',
                    branch.delivered,
                    '$deliveredPercent%',
                    AppTheme.successGreen,
                  ),
                  const SizedBox(height: 8),
                  _buildBranchStatRow(
                    'Returned',
                    branch.returned,
                    '$returnedPercent%',
                    AppTheme.rojo,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchStatRow(
    String label,
    int value,
    String percentage,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.darkGray,
            ),
          ),
        ),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            percentage,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_mall_directory_outlined,
              size: 80,
              color: AppTheme.powerBlue.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Branch Data Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.blackBean,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedBranch != null
                  ? 'No data found for ${_selectedBranch!.label} in the selected date range'
                  : 'No branch reports found for the selected date range',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.darkGray),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _resetFilters,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.marianBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppTheme.rojo),
            const SizedBox(height: 16),
            Text(
              'Analysis Failed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.rojo,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.darkGray),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchAnalysis,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.marianBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}