import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';

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
      // case 'Your Orders':
      //   return SidebarItemConfig(
      //     name: name,
      //     icon: Icons.assignment,
      //     onTap: () {
      //       context.router.push(OrdersRoute());
      //     },
      //   );
      case 'Orders':
        return SidebarItemConfig(
          name: name,
          icon: Icons.shopping_cart,
          onTap: () {
            context.router.push(OrdersRoute());
          },
        );
      case 'Warehouse':
        return SidebarItemConfig(
          name: name,
          icon: Icons.warehouse,
          onTap: () {
            // context.router.push(WarehouseRoute());
          },
        );
      // case 'Special Holded Orders':
      //   return SidebarItemConfig(
      //     name: name,
      //     icon: Icons.hourglass_bottom,
      //     onTap: () {
      //       // Add navigation here
      //     },
      //   );
      case 'RTVs':
        return SidebarItemConfig(
          name: name,
          icon: Icons.undo,
          onTap: () {
            context.router.push(OrdersRoute());

          },
        );
      case 'Delivered':
        return SidebarItemConfig(
          name: name,
          icon: Icons.check_circle,
          onTap: () {
            context.router.push(OrdersRoute());
          },
        );
      case 'Possible Redirect':
        return SidebarItemConfig(
          name: name,
          icon: Icons.trending_flat,
          onTap: () {
            context.router.push(OrdersRoute());
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
      // case 'Utilities':
      //   return SidebarItemConfig(
      //     name: name,
      //     icon: Icons.settings_applications,
      //     onTap: () {
      //       // Add navigation here
      //     },
      //   );
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
            context.router.push(OrdersRoute());
          },
        );
      case 'Redirected Orders':
        return SidebarItemConfig(
          name: name,
          icon: Icons.trending_flat,
          onTap: () {
            context.router.push(OrdersRoute());
          },
        );
      case 'Redirected Orders Today':
        return SidebarItemConfig(
          name: name,
          icon: Icons.today,
          onTap: () {
            context.router.push(OrdersRoute());
          },
        );
      case 'Returned Orders':
        return SidebarItemConfig(
          name: name,
          icon: Icons.keyboard_return,
          onTap: () {
            context.router.push(OrdersRoute());
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
            // context.router.push(const VendorPaymentsRoute());
          },
        );
      case 'COD Payments':
        return SidebarItemConfig(
          name: name,
          icon: Icons.attach_money,
          onTap: () {
            // context.router.push(const VendorCODPaymentsRoute());
          },
        );
      case 'Payment Tickets':
        return SidebarItemConfig(
          name: name,
          icon: Icons.receipt,
          onTap: () {
            // Add navigation here
          },
        );
      case 'Daily Transactions':
        return SidebarItemConfig(
          name: name,
          icon: Icons.history,
          onTap: () {
            // Add navigation here
          },
        );
      case 'Analysis':
        return SidebarItemConfig(
          name: name,
          icon: Icons.analytics,
          onTap: () {
            // Add navigation here
          },
        );
      case 'Today\'s Details':
        return SidebarItemConfig(
          name: name,
          icon: Icons.details,
          onTap: () {
            // Add navigation here
          },
        );
      case 'Pickup By Date':
        return SidebarItemConfig(
          name: name,
          icon: Icons.calendar_today,
          onTap: () {
            // Add navigation here
          },
        );
      case 'Sales Report':
        return SidebarItemConfig(
          name: name,
          icon: Icons.trending_up,
          onTap: () {
            // Add navigation here
          },
        );
      case 'Delivery Report':
        return SidebarItemConfig(
          name: name,
          icon: Icons.local_shipping,
          onTap: () {
            // Add navigation here
          },
        );
      case 'Branch Analysis':
        return SidebarItemConfig(
          name: name,
          icon: Icons.store,
          onTap: () {
            // Add navigation here
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
            // Add navigation here
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
            // Add navigation here
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
            // Add navigation here
          },
        );
      case 'Sub Branches':
        return SidebarItemConfig(
          name: name,
          icon: Icons.multiple_stop,
          onTap: () {
           
          },
        );
      default:
        return SidebarItemConfig(
          name: name,
          icon: Icons.apps,
          onTap: () {
            Navigator.pop(context);
          },
        );
    }
  }
}
