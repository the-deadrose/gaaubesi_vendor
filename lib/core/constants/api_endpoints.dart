
class ApiEndpoints {
  ApiEndpoints._();


  static const String login = '/token/';


  static const String refreshToken = '/refresh-token/';


  static const String logout = '/logout/';

  static const String vendorStats = '/dashboard/stats/';

  static const String vendorDeliveredList = '/delivered_list/';

  static const String vendorPossibleRedirect = '/possible_redirect/';

  static const String vendorReturnedOrders = '/returned_orders/';

  static const String vendorRtvList = '/rtv_list/';

  static const String vendorCreateOrder = '/create_order/';

  static const String orderList = '/order/list/';


  static const String orderDetail = '/order/detail/';

  static const String commentsTodays = '/comments/today/';

  static const String commentsAll = '/comments/all/';

  static const String replyToComment = '/comments/reply/';

  static const String  orderDetailComments = '/order/';
}
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
