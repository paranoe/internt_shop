import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:diplomeprojectmobile/app/router/guards.dart';
import 'package:diplomeprojectmobile/app/router/routes.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/screens/login_screen.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/screens/register_screen.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:diplomeprojectmobile/features/cart/presentation/screens/cart_screen.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/screens/buyer_root_screen.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/screens/home_screen.dart';
import 'package:diplomeprojectmobile/features/orders/presentation/screens/orders_screen.dart';
import 'package:diplomeprojectmobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:diplomeprojectmobile/features/seller/presentation/screens/seller_dashboard_screen.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/screens/product_list_screen.dart';
import 'package:diplomeprojectmobile/features/product/presentation/screens/product_details_screen.dart';
import 'package:diplomeprojectmobile/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:diplomeprojectmobile/features/checkout/presentation/screens/order_success_screen.dart';
import 'package:diplomeprojectmobile/features/orders/presentation/screens/order_details_screen.dart';

class AppRouter {
  AppRouter._();

  static GoRouter create(BuildContext context) {
    final authController = context.read<AuthController>();

    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: GoRouterRefreshStream(authController.stream),
      redirect: (context, state) {
        final authState = context.read<AuthController>().state;
        return RouteGuards.redirectByAuth(
          status: authState.status,
          location: state.matchedLocation,
          role: authState.user?.role,
        );
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterScreen(),
        ),

        ShellRoute(
          builder: (context, state, child) => BuyerRootScreen(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.buyerHome,
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: AppRoutes.buyerCart,
              builder: (context, state) => const CartScreen(),
            ),
            GoRoute(
              path: AppRoutes.buyerOrders,
              builder: (context, state) => const OrdersScreen(),
            ),
            GoRoute(
              path: AppRoutes.buyerProfile,
              builder: (context, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: AppRoutes.buyerProducts,
              builder: (context, state) => ProductListScreen(
                title: state.uri.queryParameters['title'] ?? 'Товары',
                categoryId: int.tryParse(
                  state.uri.queryParameters['category_id'] ?? '',
                ),
              ),
            ),
          ],
        ),

        GoRoute(
          path: AppRoutes.sellerDashboard,
          builder: (context, state) => const SellerDashboardScreen(),
        ),
        GoRoute(
          path: AppRoutes.adminDashboard,
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: AppRoutes.buyerProductDetails,
          builder: (context, state) {
            final id = int.tryParse(state.uri.queryParameters['id'] ?? '') ?? 0;
            return ProductDetailsScreen(productId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.buyerProductDetails,
          builder: (context, state) {
            final id = int.tryParse(state.uri.queryParameters['id'] ?? '') ?? 0;

            return ProductDetailsScreen(productId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.buyerCheckout,
          builder: (context, state) => const CheckoutScreen(),
        ),
        GoRoute(
          path: AppRoutes.buyerOrderSuccess,
          builder: (context, state) {
            final orderId =
                int.tryParse(state.uri.queryParameters['order_id'] ?? '') ?? 0;
            return OrderSuccessScreen(orderId: orderId);
          },
        ),
        GoRoute(
          path: AppRoutes.buyerOrderDetails,
          builder: (context, state) {
            final id = int.tryParse(state.uri.queryParameters['id'] ?? '') ?? 0;
            return OrderDetailsScreen(orderId: id);
          },
        ),
      ],
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
