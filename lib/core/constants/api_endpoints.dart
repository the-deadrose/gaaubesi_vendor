/// API Endpoints
///
/// Centralized configuration for all API endpoints used throughout the application.
/// This file provides a single source of truth for all backend API routes.
class ApiEndpoints {
  // Private constructor to prevent instantiation
  ApiEndpoints._();

  // ========================================
  // Authentication Endpoints
  // ========================================

  /// POST - User authentication endpoint
  /// Request body: { "username": string, "password": string }
  /// Response: { "token": string, "user": object }
  static const String login = '/login/';

  // ========================================
  // Vendor Endpoints
  // ========================================

  /// GET - Fetch vendor dashboard statistics
  /// Response: VendorStatsModel with dashboard metrics
  static const String vendorStats = '/vendor/stats/';

  /// GET - Fetch list of delivered orders
  /// Query params: page, destination, start_date, end_date, receiver_search, min_charge, max_charge
  /// Response: PaginatedOrderResponseModel
  static const String vendorDeliveredList = '/vendor/delivered_list/';

  /// GET - Fetch orders that can be redirected
  /// Query params: page, destination, start_date, end_date, receiver_search, min_charge, max_charge
  /// Response: PaginatedOrderResponseModel
  static const String vendorPossibleRedirect = '/vendor/possible_redirect/';

  /// GET - Fetch returned orders
  /// Query params: page, destination, start_date, end_date, receiver_search, min_charge, max_charge
  /// Response: PaginatedOrderResponseModel
  static const String vendorReturnedOrders = '/vendor/returned_orders/';

  /// GET - Fetch RTV (Return to Vendor) orders
  /// Query params: page, destination, start_date, end_date, receiver_search, min_charge, max_charge
  /// Response: PaginatedOrderResponseModel
  static const String vendorRtvList = '/vendor/rtv_list/';

  /// POST - Create a new order
  /// Request body: CreateOrderModel
  /// Response: OrderModel
  static const String vendorCreateOrder = '/vendor/create_order/';

  // ========================================
  // Order Endpoints
  // ========================================

  /// GET - Fetch paginated list of orders
  /// Query params: page, status, source_branch, destination_branch, start_date, end_date
  /// Response: PaginatedOrderResponseModel
  static const String orderList = '/order/list/';

  /// GET - Fetch detailed information about a specific order
  /// Query params: order_id
  /// Response: OrderDetailModel
  static const String orderDetail = '/order/detail/app';
}

// ========================================
// Query Parameter Keys
// ========================================

/// Common query parameter keys used across multiple endpoints
class QueryParams {
  QueryParams._();

  // Pagination
  static const String page = 'page';

  // Filtering
  static const String status = 'status';
  static const String sourceBranch = 'source_branch';
  static const String destinationBranch = 'destination_branch';
  static const String destination = 'destination';

  // Date range
  static const String startDate = 'start_date';
  static const String endDate = 'end_date';

  // Search
  static const String receiverSearch = 'receiver_search';

  // Range filters
  static const String minCharge = 'min_charge';
  static const String maxCharge = 'max_charge';

  // Order details
  static const String orderId = 'order_id';
}
