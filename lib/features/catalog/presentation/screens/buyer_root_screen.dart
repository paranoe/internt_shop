import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/app/theme/colors.dart';

class BuyerRootScreen extends StatelessWidget {
  const BuyerRootScreen({super.key, required this.child});

  final Widget child;

  int _indexFromLocation(String location) {
    if (location.startsWith(AppRoutes.buyerCart)) return 1;
    if (location.startsWith(AppRoutes.buyerOrders)) return 2;
    if (location.startsWith(AppRoutes.buyerProfile)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Главная',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart_rounded),
              label: 'Корзина',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Заказы',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                context.go(AppRoutes.buyerHome);
                break;
              case 1:
                context.go(AppRoutes.buyerCart);
                break;
              case 2:
                context.go(AppRoutes.buyerOrders);
                break;
              case 3:
                context.go(AppRoutes.buyerProfile);
                break;
            }
          },
        ),
      ),
    );
  }
}
