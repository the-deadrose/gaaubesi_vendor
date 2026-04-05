import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaaubesi_vendor/features/auth/presentation/bloc/auth_state.dart';
import 'package:gaaubesi_vendor/features/sidebar/presentation/pages/sidebar_page.dart';

@RoutePage()
class MainScaffoldPage extends StatelessWidget {
  const MainScaffoldPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.router.replaceAll([const LoginRoute()]);
        }
      },
      child: AutoTabsRouter(
        routes: [const HomeRoute(), OrdersRoute(), TicketRoute(), VendorMessagesRoute()],
        builder: (context, child) {
          final tabsRouter = AutoTabsRouter.of(context);

          return Scaffold(
            drawer: const SidebarDrawer(),
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: tabsRouter.activeIndex,
              onTap: (index) {
                tabsRouter.setActiveIndex(index);
              },
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag),
                  label: 'Orders',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.support_agent),
                  label: 'Tickets',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message),
                  label: 'Messages',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}
