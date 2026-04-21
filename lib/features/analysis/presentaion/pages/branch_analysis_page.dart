import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/configure/theme/theme.dart';
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
  BranchListEntity? _selectedBranch;
  static const int maxDaysRange = 180;
  String? _dateRangeError;
  bool _filtersExpanded = true;
  List<BranchListEntity> _filteredBranches = [];

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
    super.dispose();
  }

  bool _validateDateRange(DateTime startDate, DateTime endDate) {
    final difference = endDate.difference(startDate).inDays;
    if (difference > maxDaysRange) {
      setState(() {
        _dateRangeError =
            'Date range cannot exceed $maxDaysRange days. Current: ${difference + 1} days';
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.marianBlue,
              onPrimary: Colors.white,
              onSurface: AppTheme.blackBean,
            ),
          ),
          child: child!,
        );
      },
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

  void _applyPreset(int days) {
    final now = DateTime.now();
    _selectedEndDate = now;
    _selectedStartDate = now.subtract(Duration(days: days));
    _startDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedStartDate!);
    _endDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedEndDate!);
    setState(() {
      _dateRangeError = null;
    });
    _fetchAnalysis();
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
    });

    _fetchAnalysis();
  }

  void _selectBranch(BranchListEntity branch) {
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

  void _showBranchSearchDialog(List<BranchListEntity> branches) {
    _filteredBranches = branches;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.powerBlue.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.store_mall_directory,
                          color: AppTheme.marianBlue,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Select Branch',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.blackBean,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close,
                            color: AppTheme.darkGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: TextField(
                      autofocus: false,
                      onChanged: (query) {
                        setModalState(() {
                          if (query.isEmpty) {
                            _filteredBranches = branches;
                          } else {
                            final q = query.toLowerCase();
                            _filteredBranches = branches
                                .where(
                                  (branch) =>
                                      branch.label.toLowerCase().contains(q) ||
                                      branch.code.toLowerCase().contains(q) ||
                                      branch.value.contains(query),
                                )
                                .toList();
                          }
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name, code or ID...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppTheme.darkGray,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: AppTheme.lightGray,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.marianBlue,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _filteredBranches.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: AppTheme.powerBlue.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No branches found',
                                  style: TextStyle(
                                    color: AppTheme.darkGray,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                            itemCount: _filteredBranches.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 4),
                            itemBuilder: (context, index) {
                              final branch = _filteredBranches[index];
                              final isSelected =
                                  _selectedBranch?.value == branch.value;
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _selectBranch(branch);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.marianBlue.withValues(
                                              alpha: 0.08,
                                            )
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.marianBlue.withValues(
                                                alpha: 0.3,
                                              )
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: AppTheme.marianBlue
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            branch.label.isNotEmpty
                                                ? branch.label[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              color: AppTheme.marianBlue,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                branch.label,
                                                style: TextStyle(
                                                  fontWeight: isSelected
                                                      ? FontWeight.w700
                                                      : FontWeight.w600,
                                                  fontSize: 14,
                                                  color: AppTheme.blackBean,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${branch.code} • ID ${branch.value}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppTheme.darkGray,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: AppTheme.marianBlue,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteSmoke,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          SliverToBoxAdapter(child: _buildFilterCard()),
          SliverToBoxAdapter(
            child:
                BlocBuilder<
                  BranchReportAnalysisBloc,
                  BranchReportAnalysisState
                >(
                  builder: (context, state) {
                    final reports = _reportsFromState(state);
                    if (reports.isEmpty) return const SizedBox.shrink();
                    return Column(
                      children: [
                        _buildDistributionHero(reports),
                        _buildStatsGrid(reports),
                      ],
                    );
                  },
                ),
          ),
          SliverToBoxAdapter(
            child:
                BlocBuilder<
                  BranchReportAnalysisBloc,
                  BranchReportAnalysisState
                >(
                  builder: (context, state) {
                    return _buildContentBasedOnState(state);
                  },
                ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  List<BranchReportAnalysisEntity> _reportsFromState(
    BranchReportAnalysisState state,
  ) {
    if (state is BranchReportAnalysisLoadedState) return state.branchReports;
    if (state is BranchReportAnalysisSearchResultState) {
      return state.searchResults;
    }
    return const [];
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 140,
      backgroundColor: AppTheme.marianBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: const Text(
        'Branch Analysis',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Reset filters',
          onPressed: _resetFilters,
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.marianBlue, Color(0xFF2E5BB8)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatDateRangeLabel(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedBranch != null
                                ? _selectedBranch!.label
                                : 'All branches',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateRangeLabel() {
    if (_selectedStartDate == null || _selectedEndDate == null) return '';
    final fmt = DateFormat('MMM d, yyyy');
    return '${fmt.format(_selectedStartDate!)}  →  ${fmt.format(_selectedEndDate!)}';
  }

  Widget _buildFilterCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.marianBlue.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: () => setState(() => _filtersExpanded = !_filtersExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.marianBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: AppTheme.marianBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.blackBean,
                      ),
                    ),
                  ),
                  if (_selectedBranch != null)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '1 filter',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.successGreen,
                        ),
                      ),
                    ),
                  AnimatedRotation(
                    turns: _filtersExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _filtersExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildFilterBody(),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_dateRangeError != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.rojo.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.rojo.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppTheme.rojo, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _dateRangeError!,
                    style: const TextStyle(
                      color: AppTheme.rojo,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Preset chips
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildPresetChip('7D', 7),
              const SizedBox(width: 8),
              _buildPresetChip('30D', 30),
              const SizedBox(width: 8),
              _buildPresetChip('90D', 90),
              const SizedBox(width: 8),
              _buildPresetChip('180D', 180),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Date range row
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                controller: _startDateController,
                label: 'From',
                onTap: () => _selectDate(context, true),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: AppTheme.powerBlue.withValues(alpha: 0.8),
                size: 18,
              ),
            ),
            Expanded(
              child: _buildDateField(
                controller: _endDateController,
                label: 'To',
                onTap: () => _selectDate(context, false),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Branch selector
        BlocBuilder<BranchListBloc, BranchListState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Branch',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkGray,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                if (state is BranchListLoaded)
                  _buildBranchSelectionField(state.branchList)
                else if (state is BranchListLoading)
                  _placeholderField(
                    const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.marianBlue,
                      ),
                    ),
                  )
                else if (state is BranchListError)
                  _placeholderField(
                    const Text(
                      'Error loading branches',
                      style: TextStyle(color: AppTheme.rojo, fontSize: 12),
                    ),
                    borderColor: AppTheme.rojo.withValues(alpha: 0.3),
                  )
                else
                  _placeholderField(const SizedBox.shrink()),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _placeholderField(Widget child, {Color? borderColor}) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? AppTheme.powerBlue.withValues(alpha: 0.25),
        ),
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.lightGray,
      ),
      child: child,
    );
  }

  Widget _buildPresetChip(String label, int days) {
    final currentRange = _selectedStartDate != null && _selectedEndDate != null
        ? _selectedEndDate!.difference(_selectedStartDate!).inDays
        : -1;
    final isActive = currentRange == days;
    return GestureDetector(
      onTap: () => _applyPreset(days),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.marianBlue : AppTheme.lightGray,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppTheme.marianBlue
                : AppTheme.powerBlue.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : AppTheme.darkGray,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildBranchSelectionField(List<BranchListEntity> branches) {
    final hasSelection = _selectedBranch != null;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showBranchSearchDialog(branches),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasSelection
                ? AppTheme.marianBlue.withValues(alpha: 0.4)
                : AppTheme.powerBlue.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
          color: hasSelection
              ? AppTheme.marianBlue.withValues(alpha: 0.04)
              : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.marianBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.storefront_rounded,
                size: 16,
                color: AppTheme.marianBlue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: hasSelection
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedBranch!.label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.blackBean,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${_selectedBranch!.code} • ID ${_selectedBranch!.value}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.darkGray,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )
                  : const Text(
                      'All branches',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.darkGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
            if (hasSelection)
              GestureDetector(
                onTap: _clearBranchSelection,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.darkGray.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: AppTheme.darkGray,
                  ),
                ),
              )
            else
              const Icon(
                Icons.expand_more_rounded,
                color: AppTheme.darkGray,
                size: 22,
              ),
          ],
        ),
      ),
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
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.powerBlue.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: AppTheme.marianBlue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatDatePretty(controller.text),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.blackBean,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDatePretty(String iso) {
    try {
      final d = DateTime.parse(iso);
      return DateFormat('MMM d, yyyy').format(d);
    } catch (_) {
      return iso;
    }
  }

  Widget _buildDistributionHero(List<BranchReportAnalysisEntity> reports) {
    final totalOrders = reports.fold(0, (s, r) => s + r.total);
    if (totalOrders == 0) return const SizedBox.shrink();

    final processing = reports.fold(0, (s, r) => s + r.processingOrders);
    final delivered = reports.fold(0, (s, r) => s + r.delivered);
    final returned = reports.fold(0, (s, r) => s + r.returned);

    final deliveryRate = totalOrders > 0
        ? (delivered / totalOrders * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.marianBlue.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SfCircularChart(
                  margin: EdgeInsets.zero,
                  series: <DoughnutSeries<_DistSlice, String>>[
                    DoughnutSeries<_DistSlice, String>(
                      dataSource: [
                        _DistSlice(
                          'Delivered',
                          delivered,
                          AppTheme.successGreen,
                        ),
                        _DistSlice(
                          'Processing',
                          processing,
                          const Color(0xFFFF9800),
                        ),
                        _DistSlice('Returned', returned, AppTheme.rojo),
                      ],
                      xValueMapper: (d, _) => d.label,
                      yValueMapper: (d, _) => d.value,
                      pointColorMapper: (d, _) => d.color,
                      innerRadius: '72%',
                      radius: '95%',
                      strokeColor: Colors.white,
                      strokeWidth: 2,
                      animationDuration: 700,
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$deliveryRate%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.successGreen,
                      ),
                    ),
                    const Text(
                      'delivered',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.darkGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Distribution',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkGray,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalOrders total',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.blackBean,
                  ),
                ),
                const SizedBox(height: 10),
                _legendDot('Delivered', delivered, AppTheme.successGreen),
                const SizedBox(height: 4),
                _legendDot('Processing', processing, const Color(0xFFFF9800)),
                const SizedBox(height: 4),
                _legendDot('Returned', returned, AppTheme.rojo),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.darkGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(List<BranchReportAnalysisEntity> reports) {
    if (reports.isEmpty) return const SizedBox.shrink();

    final totalOrders = reports.fold(0, (sum, r) => sum + r.total);
    final totalProcessing = reports.fold(
      0,
      (sum, r) => sum + r.processingOrders,
    );
    final totalDelivered = reports.fold(0, (sum, r) => sum + r.delivered);
    final totalReturned = reports.fold(0, (sum, r) => sum + r.returned);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  value: totalOrders.toString(),
                  label: 'Total Orders',
                  icon: Icons.shopping_bag_rounded,
                  color: AppTheme.infoBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  value: totalProcessing.toString(),
                  label: 'Processing',
                  icon: Icons.sync_rounded,
                  color: const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  value: totalDelivered.toString(),
                  label: 'Delivered',
                  icon: Icons.check_circle_rounded,
                  color: AppTheme.successGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  value: totalReturned.toString(),
                  label: 'Returned',
                  icon: Icons.keyboard_return_rounded,
                  color: AppTheme.rojo,
                ),
              ),
            ],
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.blackBean,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.darkGray,
              fontWeight: FontWeight.w500,
            ),
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
    return const SizedBox.shrink();
  }

  Widget _buildInitialView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.marianBlue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.analytics_rounded,
              size: 44,
              color: AppTheme.marianBlue,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ready to analyze',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.blackBean,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pick a date range to view branch performance',
            style: TextStyle(fontSize: 13, color: AppTheme.darkGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildShimmerCard(height: 140),
          const SizedBox(height: 12),
          _buildShimmerCard(height: 300),
          const SizedBox(height: 12),
          _buildShimmerCard(height: 80),
          const SizedBox(height: 12),
          _buildShimmerCard(height: 80),
        ],
      ),
    );
  }

  Widget _buildShimmerCard({double height = 120}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.marianBlue.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisView(List<BranchReportAnalysisEntity> reports) {
    if (reports.isEmpty) return _buildEmptyView();
    final sorted = List<BranchReportAnalysisEntity>.from(reports)
      ..sort((a, b) => b.total.compareTo(a.total));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryChart(sorted),
        const SizedBox(height: 8),
        _buildBranchDetailsSection(sorted),
      ],
    );
  }

  Widget _buildSummaryChart(List<BranchReportAnalysisEntity> reports) {
    final isTop = reports.length > 10;
    final chartData = isTop ? reports.take(10).toList() : reports;
    final title = isTop ? 'Top 10 Branches' : 'Branch Comparison';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.marianBlue.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.marianBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  size: 16,
                  color: AppTheme.marianBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.blackBean,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isTop ? 'of ${reports.length}' : '${reports.length} branches',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkGray,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                interval: 1,
                labelRotation: -45,
                labelIntersectAction: AxisLabelIntersectAction.rotate45,
                maximumLabels: 100,
                labelStyle: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.w500,
                ),
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.darkGray,
                ),
                majorGridLines: MajorGridLines(
                  color: AppTheme.powerBlue.withValues(alpha: 0.2),
                  width: 1,
                  dashArray: const [4, 4],
                ),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
              ),
              series: <CartesianSeries<BranchReportAnalysisEntity, String>>[
                ColumnSeries<BranchReportAnalysisEntity, String>(
                  dataSource: chartData,
                  xValueMapper: (data, _) => data.name.length > 8
                      ? '${data.name.substring(0, 8)}…'
                      : data.name,
                  yValueMapper: (data, _) => data.total,
                  name: 'Orders',
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF2E5BB8), AppTheme.marianBlue],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  width: 0.55,
                  animationDuration: 700,
                ),
              ],
              tooltipBehavior: TooltipBehavior(
                enable: true,
                format: 'point.x\nOrders: point.y',
                header: '',
                canShowMarker: false,
                color: AppTheme.blackBean,
                textStyle: const TextStyle(color: Colors.white, fontSize: 11),
                borderWidth: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchDetailsSection(List<BranchReportAnalysisEntity> reports) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.marianBlue.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.marianBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.list_alt_rounded,
                  size: 16,
                  color: AppTheme.marianBlue,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Branch Performance',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.blackBean,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${reports.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkGray,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...reports.map(_buildBranchItem),
        ],
      ),
    );
  }

  Widget _buildBranchItem(BranchReportAnalysisEntity branch) {
    final total = branch.total;
    final dRate = total > 0
        ? (branch.delivered / total * 100).toStringAsFixed(0)
        : '0';

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.powerBlue.withValues(alpha: 0.15)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            collapsedIconColor: AppTheme.darkGray,
            iconColor: AppTheme.marianBlue,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.marianBlue, Color(0xFF2E5BB8)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                branch.name.isNotEmpty
                    ? branch.name.substring(0, 1).toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            title: Text(
              branch.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.blackBean,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'ID ${branch.destinationBranch} • $dRate% delivered',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$total',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.blackBean,
                    height: 1,
                  ),
                ),
                const Text(
                  'orders',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            children: [
              _buildStackedBar(branch),
              const SizedBox(height: 12),
              _buildBreakdownRow(branch),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStackedBar(BranchReportAnalysisEntity branch) {
    final total = branch.total;
    if (total == 0) {
      return Container(
        height: 8,
        decoration: BoxDecoration(
          color: AppTheme.powerBlue.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }
    final dFlex = branch.delivered;
    final pFlex = branch.processingOrders;
    final rFlex = branch.returned;

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8,
        child: Row(
          children: [
            if (dFlex > 0)
              Expanded(
                flex: dFlex,
                child: Container(color: AppTheme.successGreen),
              ),
            if (pFlex > 0)
              Expanded(
                flex: pFlex,
                child: Container(color: const Color(0xFFFF9800)),
              ),
            if (rFlex > 0)
              Expanded(
                flex: rFlex,
                child: Container(color: AppTheme.rojo),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(BranchReportAnalysisEntity branch) {
    final total = branch.total;
    String pct(int v) =>
        total > 0 ? '${(v / total * 100).toStringAsFixed(0)}%' : '0%';

    return Row(
      children: [
        Expanded(
          child: _statPill(
            color: AppTheme.successGreen,
            label: 'Delivered',
            value: '${branch.delivered}',
            percent: pct(branch.delivered),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _statPill(
            color: const Color(0xFFFF9800),
            label: 'Processing',
            value: '${branch.processingOrders}',
            percent: pct(branch.processingOrders),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _statPill(
            color: AppTheme.rojo,
            label: 'Returned',
            value: '${branch.returned}',
            percent: pct(branch.returned),
          ),
        ),
      ],
    );
  }

  Widget _statPill({
    required Color color,
    required String label,
    required String value,
    required String percent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.darkGray,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1,
                ),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: Text(
                  percent,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppTheme.darkGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.powerBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_rounded,
              size: 44,
              color: AppTheme.powerBlue.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Data Found',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.blackBean,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _selectedBranch != null
                ? 'No results for ${_selectedBranch!.label} in this date range'
                : 'No branch reports for the selected date range',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppTheme.darkGray),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _resetFilters,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reset Filters'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.marianBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.rojo.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 44,
              color: AppTheme.rojo,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.blackBean,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.darkGray),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _fetchAnalysis,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Try Again'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.marianBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistSlice {
  final String label;
  final int value;
  final Color color;
  _DistSlice(this.label, this.value, this.color);
}
