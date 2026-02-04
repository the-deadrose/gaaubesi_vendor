import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late BranchReportAnalysisBloc _bloc;
  late BranchListBloc _branchListBloc;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _branchSearchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  OrderStatusEntity? _selectedBranch;
  List<OrderStatusEntity> _filteredBranches = [];

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<BranchReportAnalysisBloc>(context);
    _branchListBloc = BlocProvider.of<BranchListBloc>(context);
    _branchListBloc.add(const FetchBranchListEvent(''));
    _fetchData();
  }

  void _fetchData() {
    final startDate = _formatDate(_startDate);
    final endDate = _formatDate(_endDate);
    final branchName = _selectedBranch != null
        ? _selectedBranch!.label
        : (_searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim());
    
    debugPrint('\n🔄 ========== PAGE: _fetchData() Called ==========');
    debugPrint('📅 Start: $startDate');
    debugPrint('📅 End: $endDate');
    debugPrint('🏢 Branch: ${branchName ?? "All"}');
    debugPrint('🔍 Selected Branch: ${_selectedBranch?.label ?? "None"}');
    debugPrint('🔍 Search Text: ${_searchController.text}');
    debugPrint('================================================\n');
    
    _bloc.add(
      FetchBranchReportAnalysisEvent(
        startDate: startDate,
        endDate: endDate,
        branchName: branchName,
      ),
    );
  }

  void _selectBranch(OrderStatusEntity branch) {
    setState(() {
      _selectedBranch = branch;
      _branchSearchController.clear();
      _filteredBranches = [];
    });
    _fetchData();
  }

  void _clearBranchSelection() {
    setState(() {
      _selectedBranch = null;
      _branchSearchController.clear();
      _filteredBranches = [];
    });
    _fetchData();
  }

  void _searchBranch(String query) {
    _bloc.add(
      SearchBranchAnalysisEvent(
        searchQuery: query,
        allData: (_bloc.state is BranchReportAnalysisLoadedState)
            ? (_bloc.state as BranchReportAnalysisLoadedState).branchReports
            : [],
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    _bloc.add(ClearSearchEvent());
    setState(() {
      _isSearching = false;
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_endDate.difference(_startDate).inDays > 180) {
          _endDate = _startDate.add(const Duration(days: 180));
        }
      });

      if (_endDate.difference(_startDate).inDays > 180) {
        if (mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Date range cannot exceed 180 days (6 months)'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }

      _fetchData();
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        if (_endDate.difference(_startDate).inDays > 180) {
          _startDate = _endDate.subtract(const Duration(days: 180));
        }
      });

      if (_endDate.difference(_startDate).inDays > 180) {
        if (mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Date range cannot exceed 180 days (6 months)'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }

      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? _buildSearchField()
            : const Text('Branch Report Analysis'),
        actions: _buildAppBarActions(),
      ),
      body: BlocProvider.value(
        value: _bloc,
        child:
            BlocConsumer<BranchReportAnalysisBloc, BranchReportAnalysisState>(
              listener: (context, state) {
                if (state is BranchReportAnalysisErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                debugPrint('\n🎨 PAGE BUILD: State = ${state.runtimeType}');
                
                if (state is BranchReportAnalysisLoadingState) {
                  debugPrint('⏳ Showing: Loading State');
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is BranchReportAnalysisEmptyState) {
                  debugPrint('📭 Showing: Empty State');
                  return _buildEmptyState();
                }

                if (state is BranchReportAnalysisLoadedState) {
                  debugPrint('✅ Showing: Loaded State (${state.filteredReports.length} items)');
                  if (state.filteredReports.isNotEmpty) {
                    for (var i = 0; i < (state.filteredReports.length > 3 ? 3 : state.filteredReports.length); i++) {
                      debugPrint('   ${i + 1}. ${state.filteredReports[i].name}');
                    }
                  }
                  return _buildLoadedState(context, state.filteredReports);
                }

                if (state is BranchReportAnalysisSearchResultState) {
                  debugPrint('🔍 Showing: Search Results (${state.searchResults.length} items)');
                  return _buildSearchResults(state.searchResults);
                }

                if (state is BranchReportAnalysisErrorState) {
                  debugPrint('❌ Showing: Error State - ${state.message}');
                }
                
                debugPrint('📍 Showing: Initial State');
                return _buildInitialState();
              },
            ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch),
      ];
    } else {
      return [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _searchFocusNode.requestFocus();
            });
          },
        ),
        IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData),
      ];
    }
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search by branch name or ID...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16),
      onChanged: _searchBranch,
      onSubmitted: (_) {
        setState(() {
          _isSearching = false;
        });
      },
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Enter branch name to search analysis',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          _buildDateFilters(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        _buildDateFilters(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.data_exploration,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchController.text.isEmpty
                      ? 'No branch reports found for the selected period'
                      : 'No results found for "${_searchController.text}"',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_formatDate(_startDate)} to ${_formatDate(_endDate)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    List<BranchReportAnalysisEntity> reports,
  ) {
    return Column(
      children: [
        _buildDateFilters(),
        const SizedBox(height: 8),
        _buildSummaryStats(reports),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              return _buildBranchCard(reports[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(List<BranchReportAnalysisEntity> results) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Found ${results.length} result${results.length != 1 ? 's' : ''}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return _buildBranchCard(results[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBranchCard(BranchReportAnalysisEntity analysis) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    analysis.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text('ID: ${analysis.destinationBranch}'),
                  backgroundColor: Colors.blue[50],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMiniCharts(analysis),
            const SizedBox(height: 12),
            _buildProgressBars(analysis),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCharts(BranchReportAnalysisEntity analysis) {
    return SizedBox(
      height: 150,
      child: Row(
        children: [
          Expanded(child: _buildMiniPieChart(analysis)),
          const SizedBox(width: 16),
          Expanded(child: _buildMiniBarChart(analysis)),
        ],
      ),
    );
  }

  Widget _buildMiniPieChart(BranchReportAnalysisEntity analysis) {
    final List<PieData> pieData = [
      PieData('Processing', analysis.processingOrders, Colors.orange),
      PieData('Delivered', analysis.delivered, Colors.green),
      PieData('Returned', analysis.returned, Colors.red),
    ];

    final nonZeroData = pieData.where((data) => data.value > 0).toList();

    return Column(
      children: [
        const Text(
          'Status Breakdown',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: nonZeroData.isEmpty
              ? const Center(
                  child: Text('No data', style: TextStyle(fontSize: 10)),
                )
              : SfCircularChart(
                  margin: EdgeInsets.zero,
                  series: <CircularSeries>[
                    PieSeries<PieData, String>(
                      dataSource: nonZeroData,
                      xValueMapper: (PieData data, _) => data.category,
                      yValueMapper: (PieData data, _) => data.value,
                      pointColorMapper: (PieData data, _) => data.color,
                      dataLabelMapper: (PieData data, _) =>
                          '${data.value}\n${data.category}',
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.inside,
                        textStyle: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                      radius: '80%',
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildMiniBarChart(BranchReportAnalysisEntity analysis) {
    final List<ChartData> chartData = [
      ChartData('Total', analysis.total, Colors.blue),
      ChartData('Proc', analysis.processingOrders, Colors.orange),
      ChartData('Del', analysis.delivered, Colors.green),
      ChartData('Ret', analysis.returned, Colors.red),
    ];

    return Column(
      children: [
        const Text(
          'Comparison',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SfCartesianChart(
            margin: EdgeInsets.zero,
            primaryXAxis: CategoryAxis(
              labelStyle: const TextStyle(fontSize: 8),
            ),
            primaryYAxis: NumericAxis(
              labelStyle: const TextStyle(fontSize: 8),
              isVisible: false,
            ),
            series: <CartesianSeries<ChartData, String>>[
              ColumnSeries<ChartData, String>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.category,
                yValueMapper: (ChartData data, _) => data.value,
                color: const Color.fromRGBO(8, 142, 255, 1),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(fontSize: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBars(BranchReportAnalysisEntity analysis) {
    final total = analysis.total;
    if (total == 0) return const SizedBox();

    return Column(
      children: [
        _buildProgressBar(
          'Processing',
          analysis.processingOrders,
          total,
          Colors.orange,
        ),
        const SizedBox(height: 4),
        _buildProgressBar('Delivered', analysis.delivered, total, Colors.green),
        const SizedBox(height: 4),
        _buildProgressBar('Returned', analysis.returned, total, Colors.red),
      ],
    );
  }

  Widget _buildProgressBar(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total * 100) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            Text(
              '$value (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(fontSize: 12, color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: total > 0 ? value / total : 0,
          backgroundColor: color.withValues(alpha: 0.2),
          color: color,
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildDateFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Period & Branch',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Branch Selection Dropdown
            BlocBuilder<BranchListBloc, BranchListState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Branch', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    if (state is BranchListLoaded) ...[
                      _buildBranchDropdown(state.branchList),
                    ] else if (state is BranchListLoading) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ] else if (state is BranchListError) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Error: ${state.message}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Start Date', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _selectStartDate(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDate(_startDate)),
                              const Icon(Icons.calendar_today, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('End Date', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _selectEndDate(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDate(_endDate)),
                              const Icon(Icons.calendar_today, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _fetchData,
                icon: const Icon(Icons.filter_alt, size: 16),
                label: const Text('Apply Filter'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchDropdown(List<OrderStatusEntity> branches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected Branch Display
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedBranch != null ? Colors.blue : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(8),
            color: _selectedBranch != null
                ? Colors.blue.withValues(alpha: 0.05)
                : Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedBranch != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedBranch!.label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Code: ${_selectedBranch!.code} | ID: ${_selectedBranch!.value}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: _clearBranchSelection,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ] else ...[
                GestureDetector(
                  onTap: () => _showBranchSearchDialog(branches),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Choose a branch...',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        // Dropdown Button
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showBranchSearchDialog(branches),
            icon: const Icon(Icons.location_on, size: 16),
            label: const Text('Select Branch'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _showBranchSearchDialog(List<OrderStatusEntity> branches) {
    _filteredBranches = branches;
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
                // Search field
                TextField(
                  controller: _branchSearchController,
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
                ),
                const SizedBox(height: 12),
                // Branch list
                Expanded(
                  child: _filteredBranches.isEmpty
                      ? const Center(child: Text('No branches found'))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredBranches.length,
                          itemBuilder: (context, index) {
                            final branch = _filteredBranches[index];
                            final isSelected =
                                _selectedBranch?.value == branch.value;
                            return ListTile(
                              selected: isSelected,
                              selectedTileColor: Colors.blue.withValues(
                                alpha: 0.1,
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
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check, color: Colors.blue)
                                  : null,
                              onTap: () {
                                this.setState(() {
                                  _selectBranch(branch);
                                });
                                Navigator.pop(context);
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
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStats(List<BranchReportAnalysisEntity> reports) {
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
          _buildStatItem('Total', totalOrders.toString(), Colors.blue),
          const SizedBox(width: 8),
          _buildStatItem(
            'Processing',
            totalProcessing.toString(),
            Colors.orange,
          ),
          const SizedBox(width: 8),
          _buildStatItem('Delivered', totalDelivered.toString(), Colors.green),
          const SizedBox(width: 8),
          _buildStatItem('Returned', totalReturned.toString(), Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _branchSearchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}

// Helper classes for charts
class ChartData {
  final String category;
  final int value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}

class PieData {
  final String category;
  final int value;
  final Color color;

  PieData(this.category, this.value, this.color);
}
