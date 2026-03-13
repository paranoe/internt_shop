import 'package:diplomeprojectmobile/features/cart/data/datasources/cart_api.dart';
import 'package:diplomeprojectmobile/features/cart/domain/entities/cart.dart';
import 'package:diplomeprojectmobile/features/cart/domain/repos/cart_repo.dart';

class CartRepoImpl implements CartRepo {
  const CartRepoImpl(this._api);

  final CartApi _api;

  @override
  Future<Cart> getCart() => _api.getCart();

  @override
  Future<void> addCartItem({required int productId, required int quantity}) {
    return _api.addCartItem(productId: productId, quantity: quantity);
  }

  @override
  Future<void> updateCartItem({
    required int cartItemId,
    int? quantity,
    bool? selectedForPurchase,
  }) {
    return _api.updateCartItem(
      cartItemId: cartItemId,
      quantity: quantity,
      selectedForPurchase: selectedForPurchase,
    );
  }

  @override
  Future<void> deleteCartItem({required int cartItemId}) {
    return _api.deleteCartItem(cartItemId: cartItemId);
  }
}
