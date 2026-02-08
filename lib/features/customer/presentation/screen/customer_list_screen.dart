import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/features/customer/domain/entity/customer_list_entity.dart';
import 'package:gaaubesi_vendor/features/customer/presentation/bloc/list/customer_bloc.dart';
import 'package:gaaubesi_vendor/features/customer/presentation/bloc/list/customer_event.dart';
import 'package:gaaubesi_vendor/features/customer/presentation/bloc/list/customer_state.dart';

@RoutePage()
class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounceTimer;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  void _fetchInitialData() {
    context.read<CustomerListBloc>().add(const FetchCustomerList());
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll * 0.8) {
      _loadMoreData();
    }
  }

  void _loadMoreData() {
    if (_isLoadingMore) return;

    final state = context.read<CustomerListBloc>().state;
    if (state is CustomerListLoaded && !state.hasReachedMax) {
      if (state.customers.isNotEmpty) {
        _isLoadingMore = true;
        context.read<CustomerListBloc>().add(
          LoadMoreCustomerList(state.currentPage + 1),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();

    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      context.read<CustomerListBloc>().add(SearchCustomerList(query));
    });
  }

  Future<void> _refreshData() async {
    _searchController.clear();
    context.read<CustomerListBloc>().add(const RefreshCustomerList());
  }

  void _onCustomerTap(CustomerList customer) {
    context.router.push(
      CustomerDetailRoute(customerId: customer.id.toString()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
        title: const Text(
          'Customers',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: theme.colorScheme.surface,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withValues(alpha:  0.6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha:  0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha:  0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha:  0.3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: theme.colorScheme.onSurface.withValues(alpha:  0.6)),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          Divider(
            height: 1,
            thickness: 1,
            color: theme.colorScheme.outline.withValues(alpha:  0.1),
          ),

          Expanded(
            child: BlocConsumer<CustomerListBloc, CustomerListState>(
              listener: (context, state) {
                if (state is CustomerListLoaded) {
                  _isLoadingMore = false;
                } else if (state is CustomerListError) {
                  _isLoadingMore = false;
                }
              },
              builder: (context, state) {
                return _buildContent(state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(CustomerListState state) {
    if (state is CustomerListLoading) {
      return _buildShimmerList();
    }

    if (state is CustomerListError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha:  0.7),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchInitialData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is CustomerListLoaded) {
      if (state.customers.isEmpty) {
        return _buildEmptyState(state);
      }

      return RefreshIndicator(
        onRefresh: _refreshData,
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: state.customers.length + (state.hasReachedMax ? 0 : 1),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 16),
          itemBuilder: (context, index) {
            if (index == state.customers.length && !state.hasReachedMax) {
              return _buildLoadMoreIndicator();
            }

            return _buildCustomerItem(state.customers[index]);
          },
        ),
      );
    }

    if (state is CustomerListSearching) {
      return _buildShimmerList();
    }

    return _buildShimmerList();
  }

  Widget _buildCustomerItem(CustomerList customer) {
    final theme = Theme.of(context);
    
    return Material(
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: () => _onCustomerTap(customer),
        highlightColor: theme.colorScheme.primary.withValues(alpha:  0.05),
        splashColor: theme.colorScheme.primary.withValues(alpha:  0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha:  0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getAvatarColor(customer.name),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    customer.name.isNotEmpty
                        ? customer.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha:  0.5),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            customer.phoneNumber,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withValues(alpha:  0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    if (customer.email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            size: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha:  0.5),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              customer.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withValues(alpha:  0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          size: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha:  0.5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${customer.packageDeliveredCount} deliveries',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha:  0.6),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(customer.createdOn),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha:  0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha:  0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading more...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha:  0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(CustomerListLoaded state) {
    final theme = Theme.of(context);
    
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                state.isSearchResult ? Icons.search_off : Icons.group_off,
                size: 80,
                color: theme.colorScheme.onSurface.withValues(alpha:  0.3),
              ),
              const SizedBox(height: 20),
              Text(
                state.isSearchResult
                    ? 'No customers found'
                    : 'No customers yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha:  0.7),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  state.isSearchResult
                      ? 'Try searching with a different term'
                      : 'Customers will appear here once they are added',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha:  0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              if (state.isSearchResult)
                ElevatedButton(
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: theme.colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Clear Search'),
                )
              else
                ElevatedButton(
                  onPressed: _refreshData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Refresh'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: 10, 
      itemBuilder: (context, index) {
        return _buildShimmerItem();
      },
    );
  }

  Widget _buildShimmerItem() {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.onSurface.withValues(alpha:  0.05);
    final highlightColor = theme.colorScheme.onSurface.withValues(alpha:  0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha:  0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildShimmerBox(
            width: 48,
            height: 48,
            shape: BoxShape.circle,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(
                  width: double.infinity,
                  height: 16,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
                
                const SizedBox(height: 12),
                
                _buildShimmerBox(
                  width: double.infinity,
                  height: 12,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
                
                const SizedBox(height: 8),
                
                _buildShimmerBox(
                  width: 120,
                  height: 12,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    Color? baseColor,
    Color? highlightColor,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return ShimmerLoading(
      baseColor: baseColor ?? Colors.grey.shade200,
      highlightColor: highlightColor ?? Colors.grey.shade300,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle 
              ? BorderRadius.circular(4)
              : null,
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    if (name.isEmpty) return Colors.grey;

    final colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
      Colors.teal.shade600,
      Colors.indigo.shade600,
      Colors.pink.shade600,
      Colors.cyan.shade600,
      Colors.deepOrange.shade600,
    ];

    final charCode = name.codeUnitAt(0);
    return colors[charCode % colors.length];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 2) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}m ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }
}

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
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
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(_gradientPosition.value, 0),
              end: Alignment(_gradientPosition.value + 1, 0),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}