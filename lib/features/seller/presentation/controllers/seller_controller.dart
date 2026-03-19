import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/features/seller/data/datasources/seller_api.dart';
import 'package:diplomeprojectmobile/features/seller/presentation/controllers/seller_state.dart';

class SellerController extends Cubit<SellerState> {
  SellerController({required SellerApi sellerApi})
    : _sellerApi = sellerApi,
      super(const SellerState());

  final SellerApi _sellerApi;

  Future<void> loadAll() async {
    emit(state.copyWith(status: SellerStatus.loading, clearError: true));

    try {
      final profile = await _sellerApi.getProfile();
      final products = await _sellerApi.getProducts();
      final orders = await _sellerApi.getOrders();

      emit(
        state.copyWith(
          status: SellerStatus.success,
          profile: profile,
          products: products,
          orders: orders,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: SellerStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> loadProducts() async {
    emit(state.copyWith(status: SellerStatus.loading, clearError: true));

    try {
      final products = await _sellerApi.getProducts();

      emit(
        state.copyWith(
          status: SellerStatus.success,
          products: products,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: SellerStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> loadOrders() async {
    emit(state.copyWith(status: SellerStatus.loading, clearError: true));

    try {
      final orders = await _sellerApi.getOrders();

      emit(
        state.copyWith(
          status: SellerStatus.success,
          orders: orders,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: SellerStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final profile = await _sellerApi.getProfile();

      emit(state.copyWith(profile: profile, clearError: true));

      return profile;
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return null;
    }
  }

  Future<bool> updateProfile({
    String? shopName,
    String? description,
    String? inn,
    String? unp,
  }) async {
    emit(state.copyWith(status: SellerStatus.saving, clearError: true));

    try {
      final profile = await _sellerApi.updateProfile(
        shopName: shopName,
        description: description,
        inn: inn,
        unp: unp,
      );

      emit(
        state.copyWith(
          status: SellerStatus.success,
          profile: profile,
          clearError: true,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(status: SellerStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    return _sellerApi.getCategories();
  }

  Future<int?> createProduct({
    required int categoryId,
    required String name,
    String? description,
    required String price,
    required int quantity,
    String currency = 'BYN',
  }) async {
    emit(state.copyWith(status: SellerStatus.saving, clearError: true));

    try {
      final productId = await _sellerApi.createProduct(
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        quantity: quantity,
        currency: currency,
      );

      final products = await _sellerApi.getProducts();

      emit(
        state.copyWith(
          status: SellerStatus.success,
          products: products,
          clearError: true,
        ),
      );

      return productId;
    } catch (e) {
      emit(
        state.copyWith(status: SellerStatus.error, errorMessage: e.toString()),
      );
      return null;
    }
  }

  Future<bool> updateProduct({
    required int productId,
    int? categoryId,
    String? name,
    String? description,
    String? price,
    int? quantity,
    String? currency,
  }) async {
    emit(state.copyWith(status: SellerStatus.saving, clearError: true));

    try {
      await _sellerApi.updateProduct(
        productId: productId,
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        quantity: quantity,
        currency: currency,
      );

      final products = await _sellerApi.getProducts();

      emit(
        state.copyWith(
          status: SellerStatus.success,
          products: products,
          clearError: true,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(status: SellerStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      await _sellerApi.deleteProduct(productId);
      final products = await _sellerApi.getProducts();

      emit(
        state.copyWith(
          status: SellerStatus.success,
          products: products,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: SellerStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getProductImages(int productId) async {
    return _sellerApi.getProductImages(productId);
  }

  Future<bool> uploadProductImage({
    required int productId,
    required String imageUrl,
    int sortOrder = 1,
  }) async {
    try {
      await _sellerApi.uploadProductImage(
        productId: productId,
        imageUrl: imageUrl,
        sortOrder: sortOrder,
      );
      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> deleteProductImage({
    required int productId,
    required int imageId,
  }) async {
    try {
      await _sellerApi.deleteProductImage(
        productId: productId,
        imageId: imageId,
      );
      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return false;
    }
  }

  Future<Map<String, dynamic>?> getOrderDetails(int orderId) async {
    try {
      return await _sellerApi.getOrderDetails(orderId);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return null;
    }
  }

  Future<bool> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    emit(state.copyWith(status: SellerStatus.saving, clearError: true));

    try {
      await _sellerApi.updateOrderStatus(orderId: orderId, status: status);

      final orders = await _sellerApi.getOrders();

      emit(
        state.copyWith(
          status: SellerStatus.success,
          orders: orders,
          clearError: true,
        ),
      );

      return true;
    } catch (e) {
      emit(
        state.copyWith(status: SellerStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }
}
