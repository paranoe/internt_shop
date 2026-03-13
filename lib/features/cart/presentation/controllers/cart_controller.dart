import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/features/cart/data/datasources/cart_api.dart';
import 'package:diplomeprojectmobile/features/cart/data/repos/cart_repo_impl.dart';
import 'package:diplomeprojectmobile/features/cart/domain/usecases/add_cart_item_usecase.dart';
import 'package:diplomeprojectmobile/features/cart/domain/usecases/delete_cart_item_usecase.dart';
import 'package:diplomeprojectmobile/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:diplomeprojectmobile/features/cart/domain/usecases/update_cart_item_usecase.dart';
import 'cart_state.dart';

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
    print('LOAD CART START');
    emit(state.copyWith(status: CartStatus.loading, clearError: true));

    try {
      final cart = await _getCart();
      print(
        'LOAD CART SUCCESS: cartId=${cart.cartId}, items=${cart.items.length}',
      );
      for (final item in cart.items) {
        print(
          'ITEM => id=${item.cartItemId}, product=${item.productName}, qty=${item.quantity}',
        );
      }

      emit(
        state.copyWith(
          status: CartStatus.success,
          cart: cart,
          clearError: true,
        ),
      );
    } catch (e, st) {
      print('LOAD CART ERROR: $e');
      print(st);
      emit(
        state.copyWith(status: CartStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> addItem({required int productId, int quantity = 1}) async {
    print('ADD ITEM START: productId=$productId, quantity=$quantity');

    try {
      await _addCartItem(productId: productId, quantity: quantity);
      print('ADD ITEM SUCCESS');
      await loadCart();
    } catch (e, st) {
      print('ADD ITEM ERROR: $e');
      print(st);
      rethrow;
    }
  }

  Future<void> increaseQty(int cartItemId, int currentQty) async {
    await _updateCartItem(cartItemId: cartItemId, quantity: currentQty + 1);
    await loadCart();
  }

  Future<void> decreaseQty(int cartItemId, int currentQty) async {
    if (currentQty <= 1) {
      await deleteItem(cartItemId);
      return;
    }

    await _updateCartItem(cartItemId: cartItemId, quantity: currentQty - 1);
    await loadCart();
  }

  Future<void> toggleSelected(int cartItemId, bool value) async {
    await _updateCartItem(cartItemId: cartItemId, selectedForPurchase: value);
    await loadCart();
  }

  Future<void> deleteItem(int cartItemId) async {
    await _deleteCartItem(cartItemId: cartItemId);
    await loadCart();
  }
}
