import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/features/cart/data/datasources/cart_api.dart';
import 'package:diplomeprojectmobile/features/cart/data/repos/cart_repo_impl.dart';
import 'package:diplomeprojectmobile/features/cart/domain/usecases/add_cart_item_usecase.dart';
import 'package:diplomeprojectmobile/features/cart/domain/usecases/delete_cart_item_usecase.dart';
import 'package:diplomeprojectmobile/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:diplomeprojectmobile/features/cart/domain/usecases/update_cart_item_usecase.dart';
import 'package:diplomeprojectmobile/features/cart/presentation/controllers/cart_state.dart';

class CartController extends Cubit<CartState> {
  CartController({required CartApi cartApi})
    : _getCart = GetCartUseCase(CartRepoImpl(cartApi)),
      _addCartItem = AddCartItemUseCase(CartRepoImpl(cartApi)),
      _updateCartItem = UpdateCartItemUseCase(CartRepoImpl(cartApi)),
      _deleteCartItem = DeleteCartItemUseCase(CartRepoImpl(cartApi)),
      super(const CartState());

  final GetCartUseCase _getCart;
  final AddCartItemUseCase _addCartItem;
  final UpdateCartItemUseCase _updateCartItem;
  final DeleteCartItemUseCase _deleteCartItem;

  Future<void> loadCart() async {
    emit(state.copyWith(status: CartStatus.loading, clearError: true));

    try {
      final cart = await _getCart();

      emit(
        state.copyWith(
          status: CartStatus.success,
          cart: cart,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CartStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> addItem({required int productId, int quantity = 1}) async {
    try {
      await _addCartItem(productId: productId, quantity: quantity);
      await loadCart();
    } catch (e) {
      emit(
        state.copyWith(status: CartStatus.error, errorMessage: e.toString()),
      );
      rethrow;
    }
  }

  Future<void> increaseQty(int cartItemId, int currentQty) async {
    try {
      await _updateCartItem(cartItemId: cartItemId, quantity: currentQty + 1);
      await loadCart();
    } catch (e) {
      emit(
        state.copyWith(status: CartStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> decreaseQty(int cartItemId, int currentQty) async {
    try {
      if (currentQty <= 1) {
        await deleteItem(cartItemId);
        return;
      }

      await _updateCartItem(cartItemId: cartItemId, quantity: currentQty - 1);
      await loadCart();
    } catch (e) {
      emit(
        state.copyWith(status: CartStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> toggleSelected(int cartItemId, bool value) async {
    try {
      await _updateCartItem(cartItemId: cartItemId, selectedForPurchase: value);
      await loadCart();
    } catch (e) {
      emit(
        state.copyWith(status: CartStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> deleteItem(int cartItemId) async {
    try {
      await _deleteCartItem(cartItemId: cartItemId);
      await loadCart();
    } catch (e) {
      emit(
        state.copyWith(status: CartStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
