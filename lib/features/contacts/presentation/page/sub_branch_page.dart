import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/contacts/domain/entity/sub_branch_entity.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/sub_branch/sub_branch_bloc.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/sub_branch/sub_branch_event.dart';
import 'package:gaaubesi_vendor/features/contacts/presentation/bloc/sub_branch/sub_branch_state.dart';

@RoutePage()
class SubBranchesScreen extends StatefulWidget {
  const SubBranchesScreen({super.key});

  @override
  State<SubBranchesScreen> createState() => _SubBranchesScreenState();
}

class _SubBranchesScreenState extends State<SubBranchesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  late SubBranchBloc _bloc;
  bool _isFirstLoad = true;
  List<SubBranchesEntity> _cachedSubBranches = [];

  @override
  void initState() {
    super.initState();
    _bloc = context.read<SubBranchBloc>();
    _loadInitialData();
    _setupScrollListener();
  }

  void _loadInitialData() {
    _bloc.add(FetchSubBranchesEvent(page: '1'));
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreData();
      }
    });
  }

  void _loadMoreData() {
    if (_bloc.hasMore && !_bloc.isLoadingMore) {
      _bloc.add(
        FetchSubBranchesEvent(
          page: (_bloc.currentPage + 1).toString(),
          searchQuery: _searchController.text.isNotEmpty
              ? _searchController.text
              : null,
        ),
      );
    }
  }

  void _onSearchSubmitted() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _searchFocusNode.unfocus();
      _isFirstLoad = true;
      _bloc.add(RefreshSubBranchesEvent(page: '1', searchQuery: query));
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _bloc.add(RefreshSubBranchesEvent(page: '1'));
  }

  void _onRefresh() {
    _isFirstLoad = true;
    _bloc.add(
      RefreshSubBranchesEvent(
        page: '1',
        searchQuery: _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: const Text('Sub Branches'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search by branch name, district, or area...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.primaryColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      fillColor: Colors.grey.shade50,
                      filled: true,
                    ),
                    onSubmitted: (_) => _onSearchSubmitted(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _onSearchSubmitted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<SubBranchBloc, SubBranchState>(
              listener: (context, state) {
                if (state is SubBranchLoadedState ||
                    state is SubBranchPaginated) {
                  _isFirstLoad = false;
                }

                if (state is SubBranchErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is SubBranchPaginatingError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return _buildBody(state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SubBranchState state) {
    if (state is SubBranchInitialState ||
        (state is SubBranchLoadingState && _isFirstLoad)) {
      return _buildLoadingScreen();
    }

    if (state is SubBranchErrorState) {
      return _buildErrorScreen(state.message);
    }

    if (state is SubBranchEmptyState) {
      return _buildEmptyScreen();
    }

    if (state is SubBranchLoadedState ||
        state is SubBranchPaginated ||
        state is SubBranchPaginating) {
      return _buildLoadedContent(state);
    }

    return const SizedBox();
  }

  Widget _buildLoadingScreen() {
    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: 6,
        itemBuilder: (context, index) {
          return _buildShimmerCard();
        },
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _bloc.add(FetchSubBranchesEvent(page: '1'));
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _searchController.text.isNotEmpty
                      ? 'No sub branches found for "${_searchController.text}"'
                      : 'No sub branches available',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (_searchController.text.isNotEmpty)
                  TextButton(
                    onPressed: _clearSearch,
                    child: const Text('Clear Search'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedContent(SubBranchState state) {
    if (state is SubBranchLoadedState) {
      _cachedSubBranches = state.subBranchesResponseEntity.results;
    } else if (state is SubBranchPaginated) {
      _cachedSubBranches = state.subBranchesResponseEntity.results;
    }

    final subBranches = _cachedSubBranches;

    final bool isLoadingMore = state is SubBranchPaginating;
    final bool isPaginateError = state is SubBranchPaginatingError;

    final isSearchResult = _searchController.text.isNotEmpty;

    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: Column(
        children: [
          if (isSearchResult)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Search Results: ${subBranches.length} found',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: _clearSearch,
                    tooltip: 'Clear search',
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: subBranches.length +
                  (isLoadingMore || isPaginateError ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= subBranches.length) {
                  return _buildBottomLoader(
                    isLoadingMore: isLoadingMore,
                    isPaginateError: isPaginateError,
                    errorMessage: isPaginateError
                        ? 'Failed to load more branches'
                        : null,
                  );
                }

                final subBranch = subBranches[index];
                return _SubBranchListItem(subBranch: subBranch);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomLoader({
    required bool isLoadingMore,
    required bool isPaginateError,
    String? errorMessage,
  }) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    } else if (isPaginateError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadMoreData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildShimmerCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerWidget(
            height: 20,
            width: 60,
            margin: const EdgeInsets.only(bottom: 12),
          ),
          
          _ShimmerWidget(
            height: 16,
            width: 120,
            margin: const EdgeInsets.only(bottom: 8),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _ShimmerWidget(
                  height: 20,
                  width: MediaQuery.of(context).size.width * 0.6,
                  margin: const EdgeInsets.only(bottom: 8),
                ),
              ),
              _ShimmerWidget(height: 24, width: 60),
            ],
          ),
          
          Row(
            children: [
              _ShimmerWidget(
                height: 16,
                width: 16,
                margin: const EdgeInsets.only(right: 4),
              ),
              Expanded(
                child: _ShimmerWidget(
                  height: 16,
                  width: MediaQuery.of(context).size.width * 0.5,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              _ShimmerWidget(
                height: 16,
                width: 16,
                margin: const EdgeInsets.only(right: 8),
              ),
              _ShimmerWidget(
                height: 16,
                width: 100,
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              _ShimmerWidget(
                height: 16,
                width: 16,
                margin: const EdgeInsets.only(right: 8),
              ),
              _ShimmerWidget(
                height: 16,
                width: 150,
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              _ShimmerWidget(
                height: 16,
                width: 16,
                margin: const EdgeInsets.only(right: 8),
              ),
              Expanded(
                child: _ShimmerWidget(
                  height: 16,
                  width: MediaQuery.of(context).size.width * 0.7,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerWidget extends StatefulWidget {
  final double height;
  final double width;
  final EdgeInsetsGeometry? margin;

  const _ShimmerWidget({
    required this.height,
    required this.width,
    this.margin,
  });

  @override
  State<_ShimmerWidget> createState() => __ShimmerWidgetState();
}

class __ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = ColorTween(
      begin: Colors.grey[200],
      end: Colors.grey[350],
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: _animation.value,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}

class _SubBranchListItem extends StatelessWidget {
  final SubBranchesEntity subBranch;

  const _SubBranchListItem({required this.subBranch});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Name and District
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subBranch.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subBranch.district,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Base Charge Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Rs ${subBranch.baseCharge}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Details Section
          _buildDetailRow(
            icon: Icons.timer,
            label: 'Arrival Time',
            value: subBranch.arrivalTime,
          ),
          
          const SizedBox(height: 8),
          
          _buildDetailRow(
            icon: Icons.location_on,
            label: 'Area Covered',
            value: subBranch.areaCovered,
          ),
          
          const SizedBox(height: 12),
          
          // Additional Info
          if (subBranch.areaCovered.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Coverage Area: ${subBranch.areaCovered}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}