import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/features/favorites/presentation/screens/favorites_screen.dart';

class BuyerRootScreen extends StatelessWidget {
  const BuyerRootScreen({super.key, required this.child});

  final Widget child;

  int _indexFromLocation(String location) {
    if (location.startsWith(AppRoutes.buyerCategories)) return 1;
    if (location.startsWith(AppRoutes.buyerCart)) return 2;
    if (location.startsWith(AppRoutes.buyerOrders)) return 3;
    if (location.startsWith(AppRoutes.buyerProfile)) return 4;
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
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: NavigationBar(
          height: 74,
          selectedIndex: currentIndex,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(CupertinoIcons.house, size: 22),
              selectedIcon: Icon(CupertinoIcons.house_fill, size: 22),
              label: 'Главная',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.square_grid_2x2, size: 22),
              selectedIcon: Icon(CupertinoIcons.square_grid_2x2_fill, size: 22),
              label: 'Категории',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.cart, size: 22),
              selectedIcon: Icon(CupertinoIcons.cart_fill, size: 22),
              label: 'Корзина',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.doc_text, size: 22),
              selectedIcon: Icon(CupertinoIcons.doc_text_fill, size: 22),
              label: 'Заказы',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.person, size: 22),
              selectedIcon: Icon(CupertinoIcons.person_fill, size: 22),
              label: 'Профиль',
            ),
          ],
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                context.go(AppRoutes.buyerHome);
                break;
              case 1:
                context.go(AppRoutes.buyerCategories);
                break;
              case 2:
                context.go(AppRoutes.buyerCart);
                break;
              case 3:
                context.go(AppRoutes.buyerOrders);
                break;
              case 4:
                context.go(AppRoutes.buyerProfile);
                break;
            }
          },
        ),
      ),
    );
  }
}
