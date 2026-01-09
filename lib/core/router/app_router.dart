import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/features/comments/presentation/pages/comments_page.dart';
import 'package:injectable/injectable.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/pages/login_page.dart';
import 'package:gaaubesi_vendor/features/home/presentation/pages/home_page.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/pages/orders_page.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/pages/create_order_page.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/pages/bulk_upload_orders_page.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/pages/extra_mileage_page.dart';
import 'package:gaaubesi_vendor/features/orderdetail/presentation/screen/order_detail_page.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/pages/stale_orders_page.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/pages/redirected_orders_page.dart';
import 'package:gaaubesi_vendor/features/orders/presentation/pages/return_orders_page.dart';
import 'package:gaaubesi_vendor/features/payments/presentation/pages/payments_page.dart';
import 'package:gaaubesi_vendor/features/support/presentation/pages/contact_page.dart';
import 'package:gaaubesi_vendor/features/support/presentation/pages/comment_page.dart';
import 'package:gaaubesi_vendor/features/utilities/presentation/pages/utilities_page.dart';
import 'package:gaaubesi_vendor/features/navigation/presentation/pages/main_scaffold.dart';
import 'package:gaaubesi_vendor/core/router/auth_guard.dart';
import 'package:gaaubesi_vendor/features/ticket/presentation/pages/tickets_page.dart';

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
        AutoRoute(page: PaymentsRoute.page, path: 'payments'),
        AutoRoute(page: UtilitiesRoute.page, path: 'utilities'),
      ],
    ),
    AutoRoute(
      page: ExtraMileageRoute.page,
      path: '/extra-mileage',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: CreateOrderRoute.page,
      path: '/create-order',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: BulkUploadOrdersRoute.page,
      path: '/bulk-upload-orders',
      guards: [AuthGuard()],
    ),
    AutoRoute(page: ContactRoute.page, path: '/contact', guards: [AuthGuard()]),
    AutoRoute(page: CommentRoute.page, path: '/comment', guards: [AuthGuard()]),
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
      page: StaleOrdersRoute.page,
      path: '/stale-orders',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: RedirectedOrdersRoute.page,
      path: '/redirected-orders',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: ReturnOrdersRoute.page,
      path: '/return-orders',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: TicketsRoute.page,
      path: '/tickets',
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
  static const String payments = '/payments';
  static const String utilities = '/utilities';
  static const String extraMileage = '/extra-mileage';
  static const String contact = '/contact';
  static const String comment = '/comment';
  static const String comments = '/comments';
  static const String tickets = '/tickets';
}
