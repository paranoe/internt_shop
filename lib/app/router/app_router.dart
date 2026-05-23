import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:diplomeprojectmobile/app/router/guards.dart';
import 'package:diplomeprojectmobile/app/router/routes.dart';

import 'package:diplomeprojectmobile/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/screens/login_screen.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/screens/register_screen.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:diplomeprojectmobile/features/cart/presentation/screens/cart_screen.dart';
import 'package:diplomeprojectmobile/features/catalog/data/datasources/catalog_api.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/controllers/catalog_controller.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/screens/buyer_root_screen.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/screens/categories_screen.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/screens/category_details_screen.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/screens/home_screen.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/screens/product_list_screen.dart';
import 'package:diplomeprojectmobile/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:diplomeprojectmobile/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:diplomeprojectmobile/features/orders/presentation/screens/order_details_screen.dart';
import 'package:diplomeprojectmobile/features/orders/presentation/screens/orders_screen.dart';
import 'package:diplomeprojectmobile/features/product/presentation/screens/product_details_screen.dart';
import 'package:diplomeprojectmobile/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:diplomeprojectmobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:diplomeprojectmobile/features/reviews/presentation/screens/add_review_screen.dart';
import 'package:diplomeprojectmobile/features/reviews/presentation/screens/product_reviews_screen.dart';
import 'package:diplomeprojectmobile/features/seller/presentation/screens/seller_dashboard_screen.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter create(BuildContext context) {
    final authController = context.read<AuthController>();

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
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
          pageBuilder: (context, state) => const MaterialPage(
            key: ValueKey('splash'),
            child: SplashScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.login,
          pageBuilder: (context, state) =>
              const MaterialPage(key: ValueKey('login'), child: LoginScreen()),
        ),
        GoRoute(
          path: AppRoutes.register,
          pageBuilder: (context, state) => const MaterialPage(
            key: ValueKey('register'),
            child: RegisterScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.verifyEmail,
          pageBuilder: (context, state) => MaterialPage(
            key: const ValueKey('verifyEmail'),
            child: VerifyEmailScreen(
              initialEmail: state.uri.queryParameters['email'],
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          pageBuilder: (context, state) => const MaterialPage(
            key: ValueKey('forgotPassword'),
            child: ForgotPasswordScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.resetPassword,
          pageBuilder: (context, state) => MaterialPage(
            key: const ValueKey('resetPassword'),
            child: ResetPasswordScreen(
              initialEmail: state.uri.queryParameters['email'],
            ),
          ),
        ),

        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => BuyerRootScreen(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.buyerHome,
              pageBuilder: (context, state) => const NoTransitionPage(
                key: ValueKey('buyerHome'),
                child: _BuyerHomePage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.buyerCategories,
              pageBuilder: (context, state) => const NoTransitionPage(
                key: ValueKey('buyerCategories'),
                child: _BuyerCategoriesPage(),
              ),
            ),
            GoRoute(
              path: AppRoutes.buyerCategoryDetails,
              pageBuilder: (context, state) {
                final categoryId = int.tryParse(
                  state.uri.queryParameters['category_id'] ?? '',
                );
                final title = state.uri.queryParameters['title'] ?? 'Категория';

                if (categoryId == null || categoryId <= 0) {
                  return const MaterialPage(
                    key: ValueKey('categoryError'),
                    child: _RouteParamErrorScreen(
                      message: 'Некорректный id категории',
                    ),
                  );
                }

                return MaterialPage(
                  key: ValueKey('buyerCategoryDetails-${state.uri}'),
                  child: BlocProvider(
                    create: (context) => CatalogController(
                      catalogApi: context.read<CatalogApi>(),
                    )..loadSubcategories(categoryId),
                    child: CategoryDetailsScreen(
                      categoryId: categoryId,
                      categoryName: title,
                    ),
                  ),
                );
              },
            ),
            GoRoute(
              path: AppRoutes.buyerProducts,
              pageBuilder: (context, state) => MaterialPage(
                key: ValueKey('buyerProducts-${state.uri}'),
                child: BlocProvider(
                  create: (context) =>
                      CatalogController(catalogApi: context.read<CatalogApi>()),
                  child: ProductListScreen(
                    title: state.uri.queryParameters['title'] ?? 'Товары',
                    categoryId: int.tryParse(
                      state.uri.queryParameters['category_id'] ?? '',
                    ),
                    subcategoryId: int.tryParse(
                      state.uri.queryParameters['subcategory_id'] ?? '',
                    ),
                    initialQuery: state.uri.queryParameters['q'] ?? '',
                  ),
                ),
              ),
            ),
            GoRoute(
              path: AppRoutes.buyerCart,
              pageBuilder: (context, state) => const NoTransitionPage(
                key: ValueKey('buyerCart'),
                child: CartScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.buyerOrders,
              pageBuilder: (context, state) => const NoTransitionPage(
                key: ValueKey('buyerOrders'),
                child: OrdersScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.buyerProfile,
              pageBuilder: (context, state) => const NoTransitionPage(
                key: ValueKey('buyerProfile'),
                child: ProfileScreen(),
              ),
            ),
          ],
        ),

        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: AppRoutes.buyerProductDetails,
          pageBuilder: (context, state) {
            final id = int.tryParse(state.uri.queryParameters['id'] ?? '');
            if (id == null || id <= 0) {
              return const MaterialPage(
                key: ValueKey('productError'),
                child: _RouteParamErrorScreen(
                  message: 'Некорректный id товара',
                ),
              );
            }

            return MaterialPage(
              key: ValueKey('buyerProductDetails-${state.uri}'),
              child: ProductDetailsScreen(productId: id),
            );
          },
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: AppRoutes.buyerCheckout,
          pageBuilder: (context, state) => const MaterialPage(
            key: ValueKey('buyerCheckout'),
            child: CheckoutScreen(),
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: AppRoutes.buyerOrderDetails,
          pageBuilder: (context, state) {
            final id = int.tryParse(state.uri.queryParameters['id'] ?? '');
            if (id == null || id <= 0) {
              return const MaterialPage(
                key: ValueKey('orderError'),
                child: _RouteParamErrorScreen(
                  message: 'Некорректный id заказа',
                ),
              );
            }

            return MaterialPage(
              key: ValueKey('buyerOrderDetails-${state.uri}'),
              child: OrderDetailsScreen(orderId: id),
            );
          },
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: AppRoutes.editProfile,
          pageBuilder: (context, state) => const MaterialPage(
            key: ValueKey('editProfile'),
            child: EditProfileScreen(),
          ),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: AppRoutes.buyerProductReviews,
          pageBuilder: (context, state) {
            final id = int.tryParse(
              state.uri.queryParameters['product_id'] ?? '',
            );
            if (id == null || id <= 0) {
              return const MaterialPage(
                key: ValueKey('reviewsError'),
                child: _RouteParamErrorScreen(
                  message: 'Некорректный id товара',
                ),
              );
            }

            return MaterialPage(
              key: ValueKey('buyerProductReviews-${state.uri}'),
              child: ProductReviewsScreen(productId: id),
            );
          },
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: AppRoutes.buyerAddReview,
          pageBuilder: (context, state) {
            final id = int.tryParse(
              state.uri.queryParameters['product_id'] ?? '',
            );
            if (id == null || id <= 0) {
              return const MaterialPage(
                key: ValueKey('addReviewError'),
                child: _RouteParamErrorScreen(
                  message: 'Некорректный id товара',
                ),
              );
            }

            return MaterialPage(
              key: ValueKey('buyerAddReview-${state.uri}'),
              child: AddReviewScreen(productId: id),
            );
          },
        ),

        GoRoute(
          path: AppRoutes.sellerDashboard,
          pageBuilder: (context, state) => const MaterialPage(
            key: ValueKey('sellerDashboard'),
            child: SellerDashboardScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.buyerFavorites,
          pageBuilder: (context, state) => const MaterialPage(
            key: ValueKey('buyerFavorites'),
            child: FavoritesScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.adminDashboard,
          pageBuilder: (context, state) => const MaterialPage(
            key: ValueKey('adminDashboard'),
            child: AdminDashboardScreen(),
          ),
        ),
      ],
    );
  }
}

class _BuyerHomePage extends StatelessWidget {
  const _BuyerHomePage();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CatalogController(catalogApi: context.read<CatalogApi>())..loadHome(),
      child: const HomeScreen(),
    );
  }
}

class _BuyerCategoriesPage extends StatelessWidget {
  const _BuyerCategoriesPage();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CatalogController(catalogApi: context.read<CatalogApi>())..loadHome(),
      child: const CategoriesScreen(),
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

class _RouteParamErrorScreen extends StatelessWidget {
  const _RouteParamErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ошибка')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
