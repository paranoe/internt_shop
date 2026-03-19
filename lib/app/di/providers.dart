import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';

import 'package:diplomeprojectmobile/core/network/dio_client.dart';
import 'package:diplomeprojectmobile/core/storage/secure_storage.dart';
import 'package:diplomeprojectmobile/features/auth/data/datasources/auth_api.dart';
import 'package:diplomeprojectmobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:diplomeprojectmobile/features/catalog/data/datasources/catalog_api.dart';
import 'package:diplomeprojectmobile/features/catalog/presentation/controllers/catalog_controller.dart';
import 'package:diplomeprojectmobile/features/product/data/datasources/product_api.dart';
import 'package:diplomeprojectmobile/features/product/presentation/controllers/product_controller.dart';
import 'package:diplomeprojectmobile/features/cart/data/datasources/cart_api.dart';
import 'package:diplomeprojectmobile/features/cart/presentation/controllers/cart_controller.dart';
import 'package:diplomeprojectmobile/features/checkout/data/datasources/checkout_api.dart';
import 'package:diplomeprojectmobile/features/checkout/presentation/controllers/checkout_controller.dart';
import 'package:diplomeprojectmobile/features/orders/data/datasources/orders_api.dart';
import 'package:diplomeprojectmobile/features/orders/presentation/controllers/orders_controller.dart';
import 'package:diplomeprojectmobile/features/profile/data/datasources/profile_api.dart';
import 'package:diplomeprojectmobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:diplomeprojectmobile/features/seller/data/datasources/seller_api.dart';
import 'package:diplomeprojectmobile/features/seller/presentation/controllers/seller_controller.dart';
import 'package:diplomeprojectmobile/features/seller/data/datasources/seller_api.dart';
import 'package:diplomeprojectmobile/features/seller/presentation/controllers/seller_controller.dart';

class AppProviders {
  AppProviders._();

  static List<SingleChildWidget> providers = [
    RepositoryProvider<SecureStorage>(create: (_) => const SecureStorage()),
    RepositoryProvider<DioClient>(
      create: (context) => DioClient(context.read<SecureStorage>()),
    ),
    RepositoryProvider<AuthApi>(
      create: (context) => AuthApi(context.read<DioClient>()),
    ),
    RepositoryProvider<CatalogApi>(
      create: (context) => CatalogApi(context.read<DioClient>()),
    ),
    BlocProvider<AuthController>(
      create: (context) => AuthController(
        secureStorage: context.read<SecureStorage>(),
        authApi: context.read<AuthApi>(),
      )..init(),
    ),
    BlocProvider<CatalogController>(
      create: (context) =>
          CatalogController(catalogApi: context.read<CatalogApi>())..loadHome(),
    ),
    RepositoryProvider<ProductApi>(
      create: (context) => ProductApi(context.read<DioClient>()),
    ),
    BlocProvider<ProductController>(
      create: (context) =>
          ProductController(productApi: context.read<ProductApi>()),
    ),
    RepositoryProvider<CartApi>(
      create: (context) => CartApi(context.read<DioClient>()),
    ),
    BlocProvider<CartController>(
      create: (context) =>
          CartController(cartApi: context.read<CartApi>())..loadCart(),
    ),
    RepositoryProvider<CheckoutApi>(
      create: (context) => CheckoutApi(context.read<DioClient>()),
    ),
    BlocProvider<CheckoutController>(
      create: (context) =>
          CheckoutController(checkoutApi: context.read<CheckoutApi>()),
    ),
    RepositoryProvider<OrdersApi>(
      create: (context) => OrdersApi(context.read<DioClient>()),
    ),
    BlocProvider<OrdersController>(
      create: (context) =>
          OrdersController(ordersApi: context.read<OrdersApi>()),
    ),
    RepositoryProvider<ProfileApi>(
      create: (context) => ProfileApi(context.read<DioClient>()),
    ),
    BlocProvider<ProfileController>(
      create: (context) =>
          ProfileController(profileApi: context.read<ProfileApi>()),
    ),
    RepositoryProvider<SellerApi>(
      create: (context) => SellerApi(context.read<DioClient>()),
    ),
    BlocProvider<SellerController>(
      create: (context) =>
          SellerController(sellerApi: context.read<SellerApi>())
            ..loadProducts(),
    ),
    RepositoryProvider<SellerApi>(
      create: (context) => SellerApi(context.read<DioClient>()),
    ),
    BlocProvider<SellerController>(
      create: (context) =>
          SellerController(sellerApi: context.read<SellerApi>())..loadAll(),
    ),
  ];
}
