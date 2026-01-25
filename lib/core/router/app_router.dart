import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/pages/comments_page.dart';
import 'package:gaaubesi_vendor/features/customer/presentation/screen/customer_detail_screen.dart';
import 'package:gaaubesi_vendor/features/customer/presentation/screen/customer_list_screen.dart';
import 'package:gaaubesi_vendor/features/notice/domain/entity/notice_list_entity.dart';
import 'package:gaaubesi_vendor/features/notice/presentation/screen/notice_detail_screen.dart';
import 'package:gaaubesi_vendor/features/notice/presentation/screen/notice_screen.dart';
import 'package:gaaubesi_vendor/features/ticket/domain/entity/pending_ticket_list_entity.dart';
import 'package:gaaubesi_vendor/features/ticket/presentation/pages/create_ticket_page.dart';
import 'package:gaaubesi_vendor/features/ticket/presentation/pages/tickets_detail_page.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/pages/login_page.dart';
import 'package:gaaubesi_vendor/features/home/presentation/pages/home_page.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/pages/orders_page.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/pages/create_order_page.dart';
import 'package:gaaubesi_vendor/features/orderdetail/presentation/screen/order_detail_page.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/pages/redirected_orders_page.dart';
import 'package:gaaubesi_vendor/features/navigation/presentation/pages/main_scaffold.dart';
import 'package:gaaubesi_vendor/core/router/auth_guard.dart';
import 'package:gaaubesi_vendor/features/ticket/presentation/pages/tickets_page.dart';
import 'package:gaaubesi_vendor/features/cod_transfer/presentation/page/cod_transfer_list_page.dart';
import 'package:gaaubesi_vendor/features/daily_transections/presentation/page/daily_transaction_screen.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/pages/todays_redirected_orders_screen.dart';
import 'package:gaaubesi_vendor/features/calculate_charge/presentation/page/calculate_delivery_charge_screen.dart';
import 'package:gaaubesi_vendor/features/payment_request/presentation/page/create_payment_screen.dart';
import 'package:gaaubesi_vendor/features/payment_request/presentation/page/payment_request_list_screen.dart';
import 'package:gaaubesi_vendor/features/message/presetantion/page/vendor_message.dart';
import 'package:gaaubesi_vendor/features/vendor_info/presentaion/page/vendor_info_screen.dart';
import 'package:gaaubesi_vendor/features/extra_mileage/presentation/page/extra_mileage_list.dart';

part 'app_router.gr.dart';

@singleton
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(
      page: MainScaffoldRoute.page,
      path: '/',
      initial: true,
      guards: [AuthGuard()],
      children: [
        AutoRoute(page: HomeRoute.page, path: 'home', initial: true),
        AutoRoute(page: OrdersRoute.page, path: 'orders'),
      ],
    ),

    AutoRoute(
      page: CreateOrderRoute.page,
      path: '/create-order',
      guards: [AuthGuard()],
    ),

    AutoRoute(
      page: CommentsRoute.page,
      path: '/comments',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: OrderDetailRoute.page,
      path: '/order-detail/:orderId',
      guards: [AuthGuard()],
    ),

    AutoRoute(
      page: RedirectedOrdersRoute.page,
      path: '/redirected-orders',
      guards: [AuthGuard()],
    ),

    AutoRoute(page: TicketRoute.page, path: '/tickets', guards: [AuthGuard()]),

    AutoRoute(
      page: CustomerListRoute.page,
      path: '/customer-list',
      guards: [AuthGuard()],
    ),

    AutoRoute(
      page: NoticeListRoute.page,
      path: '/notice-list',
      guards: [AuthGuard()],
    ),

    AutoRoute(
      page: NoticeDetailRoute.page,
      path: '/notice-detail/:noticeId',
      guards: [AuthGuard()],
    ),

    AutoRoute(
      page: TicketDetailRoute.page,
      path: '/ticket-detail/:ticketId',
      guards: [AuthGuard()],
    ),

    AutoRoute(
      page: CreateTicketRoute.page,
      path: '/create-ticket',
      guards: [AuthGuard()],
    ),

    AutoRoute(
      page: CodTransferListRoute.page,
      path: '/cod-transfer-list',
      guards: [AuthGuard()],
    ),

    AutoRoute(
      page: DailyTransactionRoute.page,
      path: '/daily-transactions',
      guards: [AuthGuard()],
    ),

    AutoRoute(
      page: TodaysRedirectedOrdersRoute.page,
      path: '/todays-redirected-orders',
      guards: [AuthGuard()],
    ),

    AutoRoute(
      page: CalculateDeliveryChargeRoute.page,
      path: '/calculate-delivery-charge',
      guards: [AuthGuard()],
    ),

    AutoRoute(
      page: PaymentRequestRoute.page,
      path: '/payment-request',
      guards: [AuthGuard()],
    ),

    AutoRoute(
      page: PaymentRequestListRoute.page,
      path: '/payment-request-list',
      guards: [AuthGuard()],
    ),

    AutoRoute(
      page: VendorMessagesRoute.page,
      path: '/vendor-messages',
      guards: [AuthGuard()],
    ),

    AutoRoute(
      page: CustomerDetailRoute.page,
      path: '/customer-detail/:id',
      guards: [AuthGuard()],
    ),

    AutoRoute(
      page: VendorInfoRoute.page,
      path: '/vendor-info',
      guards: [AuthGuard()],
    ),

    AutoRoute(
      page: ExtraMileageRoute.page,
      path: '/extra-mileage',
      guards: [AuthGuard()],
    ),

  
  ];
}

// Extension to match old routing names
extension AppRoutesExtension on AppRouter {
  static const String login = '/login';
  static const String home = '/home';
  static const String orders = '/orders';
  static const String deliveredOrders = '/delivered-orders';
  static const String extraMileage = '/extra-mileage';
  static const String contact = '/contact';
  static const String comments = '/comments';
  static const String tickets = '/tickets';
  static const String customerList = '/customer-list';
  static const String noticeScreen = '/notice-list';
  static const String noticeDetailScreen = '/notice-detail';
  static const String ticketDetailScreen = '/ticket-detail';
  static const String createTicket = '/create-ticket';
  static const String codTransferList = '/cod-transfer-list';
  static const String dailyTransaction = '/daily-transaction';
  static const String todaysRedirectedOrders = '/todays-redirected-orders';
  static const String calculateDeliveryCharge = '/calculate-delivery-charge';
  static const String orderDetail = '/payment-request';
  static const String redirectedOrders = '/payment-request-list';
  static const String vendorMessages = '/vendor-messages';
  static const String customerDetail = '/customer-detail';
  static const String vendorInfo = '/vendor-info';
  static const String extraMileagePage = '/extra-mileage';
}
