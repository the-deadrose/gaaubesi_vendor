import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/app/orders/domain/entities/order_entity.dart';

/// Search delegate for orders with custom UI and search history
class OrderSearchDelegate extends SearchDelegate<OrderEntity?> {
  final List<OrderEntity> allOrders;
  final List<String> recentSearches;
  final Function(String) onSearchQueryChanged;
  final VoidCallback? onClearRecentSearches;

  OrderSearchDelegate({
    required this.allOrders,
    this.recentSearches = const [],
    required this.onSearchQueryChanged,
    this.onClearRecentSearches,
  }) : super(
         searchFieldLabel: 'Search orders...',
         searchFieldStyle: const TextStyle(fontSize: 16),
       );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          tooltip: 'Clear',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
      tooltip: 'Back',
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _searchOrders(query);

    if (results.isEmpty) {
      return _buildEmptyState(context, 'No orders found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final order = results[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Row(
              children: [
                Text(
                  '${order.orderId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      order.lastDeliveryStatus,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.lastDeliveryStatus,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(order.lastDeliveryStatus),
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.receiverName,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          order.receiverAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[400],
            ),
            onTap: () => close(context, order),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildRecentSearches(context);
    }

    final suggestions = _searchOrders(query).take(5).toList();

    if (suggestions.isEmpty) {
      return _buildEmptyState(context, 'No suggestions');
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final order = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.search_rounded),
          title: RichText(text: _highlightQuery('${order.orderId}', query)),
          subtitle: Text(
            order.receiverName,
            style: const TextStyle(fontSize: 12),
          ),
          onTap: () {
            query = order.orderId.toString();
            showResults(context);
          },
        );
      },
    );
  }

  List<OrderEntity> _searchOrders(String searchQuery) {
    if (searchQuery.isEmpty) return [];

    final lowerQuery = searchQuery.toLowerCase();
    return allOrders.where((order) {
      return order.orderId.toString().contains(lowerQuery) ||
          order.receiverName.toLowerCase().contains(lowerQuery) ||
          order.receiverAddress.toLowerCase().contains(lowerQuery) ||
          order.receiverNumber.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  TextSpan _highlightQuery(String text, String query) {
    if (query.isEmpty) {
      return TextSpan(
        text: text,
        style: const TextStyle(color: Colors.black),
      );
    }

    final matches = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        matches.add(
          TextSpan(
            text: text.substring(start),
            style: const TextStyle(color: Colors.black),
          ),
        );
        break;
      }

      if (index > start) {
        matches.add(
          TextSpan(
            text: text.substring(start, index),
            style: const TextStyle(color: Colors.black),
          ),
        );
      }

      matches.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      );

      start = index + query.length;
    }

    return TextSpan(children: matches);
  }

  Widget _buildRecentSearches(BuildContext context) {
    if (recentSearches.isEmpty) {
      return _buildEmptyState(
        context,
        'Start typing to search orders',
        icon: Icons.search_rounded,
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              if (onClearRecentSearches != null)
                TextButton(
                  onPressed: onClearRecentSearches,
                  child: const Text('Clear'),
                ),
            ],
          ),
        ),
        ...recentSearches.map(
          (search) => ListTile(
            leading: const Icon(Icons.history_rounded),
            title: Text(search),
            trailing: const Icon(Icons.north_west_rounded, size: 16),
            onTap: () {
              query = search;
              showResults(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String message, {
    IconData icon = Icons.inbox_outlined,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'in transit':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
