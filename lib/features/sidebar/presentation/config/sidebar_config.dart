import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';

void _showComingSoon(BuildContext context, String featureName) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$featureName is coming soon!'),
      duration: const Duration(seconds: 2),
    ),
  );
}

class SidebarItemConfig {
  final String name;
  final IconData icon;
  final VoidCallback onTap;

  const SidebarItemConfig({
    required this.name,
    required this.icon,
    required this.onTap,
  });
}

class SidebarConfig {
  static SidebarItemConfig getConfigByName(String name, BuildContext context) {
    switch (name) {
      case 'Dashboard':
        return SidebarItemConfig(
          name: name,
          icon: Icons.dashboard,
          onTap: () {
            Navigator.pop(context);
          },
        );
      case 'Your Orders':
        return SidebarItemConfig(
          name: name,
          icon: Icons.assignment,
          onTap: () {
            _showComingSoon(context, 'Your Orders');
          },
        );
      case 'Orders':
        return SidebarItemConfig(
          name: name,
          icon: Icons.shopping_cart,
          onTap: () {
            context.router.push(OrdersRoute(initialTab: 0));
          },
        );
      case 'Warehouse':
        return SidebarItemConfig(
          name: name,
          icon: Icons.warehouse,
          onTap: () {
            context.router.push(OrdersRoute(initialTab: 5));
          },
        );
      case 'Special Holded Orders':
        return SidebarItemConfig(
          name: name,
          icon: Icons.hourglass_bottom,
          onTap: () {
            _showComingSoon(context, 'Special Holded Orders');
          },
        );
      case 'RTVs':
        return SidebarItemConfig(
          name: name,
          icon: Icons.undo,
          onTap: () {
            context.router.push(OrdersRoute(initialTab: 4));
          },
        );
      case 'Delivered':
        return SidebarItemConfig(
          name: name,
          icon: Icons.check_circle,
          onTap: () {
            context.router.push(OrdersRoute(initialTab: 1));
          },
        );
      case 'Possible Redirect':
        return SidebarItemConfig(
          name: name,
          icon: Icons.trending_flat,
          onTap: () {
            context.router.push(OrdersRoute(initialTab: 2));
          },
        );
      case 'Your Customers':
        return SidebarItemConfig(
          name: name,
          icon: Icons.people,
          onTap: () {
            context.router.push(const CustomerListRoute());
          },
        );
      case 'Utilities':
        return SidebarItemConfig(
          name: name,
          icon: Icons.settings_applications,
          onTap: () {
            _showComingSoon(context, 'Utilities');
          },
        );
      case 'Tickets':
        return SidebarItemConfig(
          name: name,
          icon: Icons.confirmation_number,
          onTap: () {
            context.router.push(TicketRoute());
          },
        );
      case 'Messages':
        return SidebarItemConfig(
          name: name,
          icon: Icons.message,
          onTap: () {
            context.router.push(const VendorMessagesRoute());
          },
        );
      case 'Notices':
        return SidebarItemConfig(
          name: name,
          icon: Icons.notifications,
          onTap: () {
            context.router.push(const NoticeListRoute());
          },
        );
      case 'Stale Orders':
        return SidebarItemConfig(
          name: name,
          icon: Icons.access_time,
          onTap: () {
            context.router.push(OrdersRoute(initialTab: 6));
          },
        );
      case 'Redirected Orders':
        return SidebarItemConfig(
          name: name,
          icon: Icons.trending_flat,
          onTap: () {
            context.router.push(OrdersRoute(initialTab: 7));
          },
        );
      case 'Redirected Orders Today':
        return SidebarItemConfig(
          name: name,
          icon: Icons.today,
          onTap: () {
            context.router.push(OrdersRoute(initialTab: 8));
          },
        );
      case 'Returned Orders':
        return SidebarItemConfig(
          name: name,
          icon: Icons.keyboard_return,
          onTap: () {
            context.router.push(OrdersRoute(initialTab: 3));
          },
        );
      case 'Comments':
        return SidebarItemConfig(
          name: name,
          icon: Icons.comment,
          onTap: () {
            context.router.push(CommentsRoute());
          },
        );
      case 'Today\'s Comments':
        return SidebarItemConfig(
          name: name,
          icon: Icons.chat_bubble,
          onTap: () {
            context.router.push(CommentsRoute());
          },
        );
      case 'Payments':
        return SidebarItemConfig(
          name: name,
          icon: Icons.payment,
          onTap: () {
            context.router.push(const PaymentRequestListRoute());
          },
        );
      case 'COD Payments':
        return SidebarItemConfig(
          name: name,
          icon: Icons.attach_money,
          onTap: () {
            context.router.push(const CodTransferListRoute());
          },
        );
      case 'Payment Tickets':
        return SidebarItemConfig(
          name: name,
          icon: Icons.receipt,
          onTap: () {
            context.router.push(const PaymentRequestListRoute());
          },
        );
      case 'Daily Transactions':
        return SidebarItemConfig(
          name: name,
          icon: Icons.history,
          onTap: () {
            context.router.push(DailyTransactionRoute());
          },
        );
      case 'Analysis':
        return SidebarItemConfig(
          name: name,
          icon: Icons.analytics,
          onTap: () {
            _showComingSoon(context, 'Analysis');
          },
        );
      case 'Today\'s Details':
        return SidebarItemConfig(
          name: name,
          icon: Icons.details,
          onTap: () {
            context.router.push(const TodayDetailRoute());
          },
        );
      case 'Pickup By Date':
        return SidebarItemConfig(
          name: name,
          icon: Icons.calendar_today,
          onTap: () {
            context.router.push(const PickupOrderAnalysisRoute());
          },
        );
      case 'Sales Report':
        return SidebarItemConfig(
          name: name,
          icon: Icons.trending_up,
          onTap: () {
            context.router.push(const SalesReportAnalysisRoute());
          },
        );
      case 'Delivery Report':
        return SidebarItemConfig(
          name: name,
          icon: Icons.local_shipping,
          onTap: () {
            context.router.push(const DeliveryReportAnalysisRoute());
          },
        );
      case 'Branch Analysis':
        return SidebarItemConfig(
          name: name,
          icon: Icons.store,
          onTap: () {
            context.router.push(const BranchReportAnalysisRoute());
          },
        );
      case 'Staffs':
        return SidebarItemConfig(
          name: name,
          icon: Icons.person_3,
          onTap: () {
            context.router.push(const StaffListRoute());
          },
        );
      case 'Resources':
        return SidebarItemConfig(
          name: name,
          icon: Icons.folder_open,
          onTap: () {
            context.router.push(const ResourcesListRoute());
          },
        );
      case 'Extra Mileage':
        return SidebarItemConfig(
          name: name,
          icon: Icons.route,
          onTap: () {
            context.router.push(const ExtraMileageRoute());
          },
        );
      case 'GBL Contacts':
        return SidebarItemConfig(
          name: name,
          icon: Icons.contacts,
          onTap: () {
            _showComingSoon(context, 'GBL Contacts');
          },
        );
      case 'Service Stations':
        return SidebarItemConfig(
          name: name,
          icon: Icons.handyman,
          onTap: () {
            context.router.push(const ServiceStationRoute());
          },
        );
      case 'Head Office':
        return SidebarItemConfig(
          name: name,
          icon: Icons.business,
          onTap: () {
            context.router.push(const HeadOfficeContactsRoute());
          },
        );
      case 'Redirect Stations':
        return SidebarItemConfig(
          name: name,
          icon: Icons.transit_enterexit,
          onTap: () {
            context.router.push(const RedirectStationListRoute());
          },
        );
      case 'Sub Branches':
        return SidebarItemConfig(
          name: name,
          icon: Icons.multiple_stop,
          onTap: () {
            context.router.push(const SubBranchesRoute());
          },
        );
      default:
        return SidebarItemConfig(name: name, icon: Icons.apps, onTap: () {});
    }
  }
}
