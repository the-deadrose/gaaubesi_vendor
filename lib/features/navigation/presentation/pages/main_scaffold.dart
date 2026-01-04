import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:gaaubesi_vendor/core/router/app_router.dart';
import 'package:gaaubesi_vendor/features/navigation/presentation/widgets/app_navigation_bar.dart';
import 'package:gaaubesi_vendor/features/navigation/presentation/widgets/app_drawer.dart';

@RoutePage()
class MainScaffoldPage extends StatelessWidget {
  const MainScaffoldPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        HomeRoute(),
        OrdersRoute(),
        PaymentsRoute(),
        UtilitiesRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        
        return Scaffold(
          drawer: const AppDrawer(),
          body: child,
          bottomNavigationBar: AppNavigationBar(
            currentIndex: tabsRouter.activeIndex,
            onTap: (index) {
              tabsRouter.setActiveIndex(index);
            },
          ),
        );
      },
    );
  }
}
