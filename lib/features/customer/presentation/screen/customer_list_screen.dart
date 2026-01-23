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
    
    // Initialize data when screen loads
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
        title: const Text('Customers'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
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
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CustomerListError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
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

    if (state is CustomerListLoaded) {
      if (state.customers.isEmpty) {
        return _buildEmptyState(state);
      }

      return RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: state.customers.length + (state.hasReachedMax ? 0 : 1),
          padding: const EdgeInsets.only(bottom: 16),
          itemBuilder: (context, index) {
            if (index == state.customers.length && !state.hasReachedMax) {
              return _buildLoadMoreIndicator();
            }

            return _buildCustomerCard(state.customers[index]);
          },
        ),
      );
    }

    if (state is CustomerListSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching...'),
          ],
        ),
      );
    }

    // Initial state
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildCustomerCard(CustomerList customer) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: InkWell(
        onTap: () => _onCustomerTap(customer),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(Icons.phone, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            customer.phoneNumber,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
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
                          const Icon(Icons.email, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              customer.email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Icons.local_shipping,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${customer.packageDeliveredCount} deliveries',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(customer.createdOn),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading more...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(CustomerListLoaded state) {
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
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 20),
              Text(
                state.isSearchResult
                    ? 'No customers found'
                    : 'No customers yet',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                state.isSearchResult
                    ? 'Try a different search term'
                    : 'Customers will appear here once added',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (state.isSearchResult)
                ElevatedButton(
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                  child: const Text('Clear Search'),
                )
              else
                ElevatedButton(
                  onPressed: _refreshData,
                  child: const Text('Refresh'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    if (name.isEmpty) return Colors.grey;

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
      Colors.deepOrange,
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
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d ago';
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