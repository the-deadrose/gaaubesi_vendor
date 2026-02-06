
class ApiEndpoints {
  ApiEndpoints._();


  static const String login = '/token/';


  static const String refreshToken = '/token/refresh/';


  static const String logout = '/logout/';

  static const String vendorStats = '/dashboard/stats/';

  static const String vendorDeliveredList = '/delivered_list/';

  static const String vendorPossibleRedirect = '/possible-redirect/';

  static const String vendorReturnedOrders = '/returned_orders/';

  static const String vendorRtvList = '/rtv_list/';

  static const String vendorCreateOrder = '/order/create/';

  static const String orderList = '/order/list/';

  static const String staleOrders = '/stale-orders/';

  static const String orderDetail = '/order/detail/';

  static const String commentsTodays = '/comments/today/';

  static const String commentsAll = '/comments/all/';

  static const String replyToComment = '/comments/reply/';

  static const String  orderDetailComments = '/order/';

  static const String createCommentOrderDetail = '/comments/create/';

  static const String replyToCommentOrderDetail = '/comments/reply/';

  static const String createTicket = '/add/ticket/';

  static const String ticketList = '/tickets/';

  static const String branchList = '/branch/list/';

  static const String editOrder = '/order/update/';

  static const String pickupPoints = '/pickup_points/';

  static const String warehouseOrderList = '/warehouse/';
  
  static const String codTransfer = '/cod-transfer/';

  static const String customerList = '/customers/';

  static const String noticeList = '/notices/';

  static const String dailyTransections = '/daily-transactions/';

  static const String redirectedOrders = '/redirect-orders/';

  static const String redirectedOrdersToday = '/redirect-orders/today/';

  static const String calculateDeliveryCharge = '/order/delivery-charge/calculate/';

  static const String frequentlyUsedPaymentMethods = '/payment/request/';

  static const String paymentRequest = '/payment-tickets/';

  static const String vendorMessages = '/messages/';

  static const String customerDetail = '/account/customer/';

  static const String vendorInfo = '/account/vendor/';

  static const String extraMileageList = '/extra-mileage/list/';

  static const String changePassword = '/account/vendor/change-password/';

  static const String editProfile = '/account/vendor/edit/';

  static const String headOfficeContacts = '/head-office/';

  static const String serviceStations = '/services/service-station/';

  static const String redirectStations = '/services/redirect-station/';

  static const String deliveryReportAnalysis = '/analysis/delivery-report/';

  static const String salesReportAnalysis = '/analysis/sales-report/';

  static const String branchReportAnalysis = '/analysis/branch-analysis/';

  static const String pickupOrderAnalysis = '/analysis/pickup-orders/';

  static const String staffList = '/staff/vendor-staff-list/';

  static const String vendorStaffInfoAPI = '/staff/vendor-staff/';

  static const String staffPermissionsAPI = '/staff/vendor-staff/';

  static const String createStaff = '/staff/vendor-staff-create/';
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
