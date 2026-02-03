import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/features/branch/domain/entity/redirect_station_list_entity.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/redirect_stations/redirect_station_list_bloc.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/redirect_stations/redirect_station_list_event.dart';
import 'package:gaaubesi_vendor/features/branch/presentation/bloc/redirect_stations/redirect_station_list_state.dart';

@RoutePage()
class RedirectStationListScreen extends StatefulWidget {
  const RedirectStationListScreen({super.key});

  @override
  State<RedirectStationListScreen> createState() =>
      _RedirectStationListScreenState();
}

class _RedirectStationListScreenState extends State<RedirectStationListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  late RedirectStationListBloc _bloc;
  bool _isFirstLoad = true;
  List<RedirectStationEntity> _cachedStations = [];

  @override
  void initState() {
    super.initState();
    _bloc = context.read<RedirectStationListBloc>();
    _loadInitialData();
    _setupScrollListener();
  }

  void _loadInitialData() {
    _bloc.add(FetchRedirectStationListEvent(page: '1'));
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
        FetchRedirectStationListEvent(
          page: '1',
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
      _bloc.add(RefreshRedirectStationListEvent(page: '1', searchQuery: query));
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _bloc.add(RefreshRedirectStationListEvent(page: '1'));
  }

  void _onRefresh() {
    _isFirstLoad = true;
    _bloc.add(
      RefreshRedirectStationListEvent(
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
        title: const Text('Redirect Stations'),
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
                      hintText: 'Search by branch name, code, or location...',
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
            child:
                BlocConsumer<RedirectStationListBloc, RedirectStationListState>(
                  listener: (context, state) {
                    if (state is RedirectStationListLoaded ||
                        state is RedirectStationListPaginated) {
                      _isFirstLoad = false;
                    }

                    if (state is RedirectStationListError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else if (state is RedirectStationListPaginateError) {
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

  Widget _buildBody(RedirectStationListState state) {
    if (state is RedirectStationListInitial ||
        (state is RedirectStationListLoading && _isFirstLoad)) {
      return _buildLoadingScreen();
    }

    if (state is RedirectStationListError) {
      return _buildErrorScreen(state.message);
    }

    if (state is RedirectStationListEmpty) {
      return _buildEmptyScreen();
    }

    if (state is RedirectStationListLoaded ||
        state is RedirectStationListPaginated ||
        state is RedirectStationListPaginating) {
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
                _bloc.add(FetchRedirectStationListEvent(page: '1'));
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
                      ? 'No stations found for "${_searchController.text}"'
                      : 'No redirect stations available',
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

  Widget _buildLoadedContent(RedirectStationListState state) {
    if (state is RedirectStationListLoaded) {
      _cachedStations = state.redirectStationList.results;
    } else if (state is RedirectStationListPaginated) {
      _cachedStations = state.redirectStationList.results;
    }

    final stations = _cachedStations;

    final bool isLoadingMore = state is RedirectStationListPaginating;
    final bool isPaginateError = state is RedirectStationListPaginateError;

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
                    'Search Results: ${stations.length} found',
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
              itemCount:
                  stations.length + (isLoadingMore || isPaginateError ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= stations.length) {
                  return _buildBottomLoader(
                    isLoadingMore: isLoadingMore,
                    isPaginateError: isPaginateError,
                    errorMessage: isPaginateError
                        ? 'Failed to load more stations'
                        : null,
                  );
                }

                final station = stations[index];
                return _RedirectStationListItem(station: station);
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

          _ShimmerWidget(
            height: 16,
            width: 150,
            margin: const EdgeInsets.only(bottom: 8),
          ),

          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _ShimmerWidget(
                  height: 24,
                  width: 24,
                  margin: const EdgeInsets.only(right: 12),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerWidget(
                        height: 16,
                        width: MediaQuery.of(context).size.width * 0.5,
                        margin: const EdgeInsets.only(bottom: 4),
                      ),
                      _ShimmerWidget(
                        height: 14,
                        width: MediaQuery.of(context).size.width * 0.4,
                      ),
                    ],
                  ),
                ),
                _ShimmerWidget(height: 20, width: 40),
              ],
            ),
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

class _RedirectStationListItem extends StatelessWidget {
  final RedirectStationEntity station;

  const _RedirectStationListItem({required this.station});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'ID: ${station.id}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 12),

          _buildBranchSection(
            title: 'HOME BRANCH',
            branch: station.homeBranch,
            isHomeBranch: true,
            theme: theme,
          ),

          const SizedBox(height: 16),

          _buildRedirectBranchesSection(theme),
        ],
      ),
    );
  }

  Widget _buildBranchSection({
    required String title,
    required BranchEntity branch,
    required bool isHomeBranch,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isHomeBranch ? theme.primaryColor : Colors.green,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        _buildBranchInfo(branch, isHomeBranch: isHomeBranch),
      ],
    );
  }

  Widget _buildBranchInfo(BranchEntity branch, {bool isHomeBranch = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                branch.name,
                style: TextStyle(
                  fontSize: isHomeBranch ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                branch.code,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${branch.district}, ${branch.province}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRedirectBranchesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'REDIRECT BRANCHES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.green,
                letterSpacing: 0.5,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${station.redirectBranches.length}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...station.redirectBranches.map((branch) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 12,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${branch.district}, ${branch.province}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          Text(
                            branch.code,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
