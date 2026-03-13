import 'package:diplomeprojectmobile/features/cart/domain/entities/cart.dart';

abstract class CartRepo {
  Future<Cart> getCart();

  Future<void> addCartItem({
    required int productId,
    required int quantity,
  });

  Future<void> updateCartItem({
    required int cartItemId,
    int? quantity,
    bool? selectedForPurchase,
  });

  Future<void> deleteCartItem({
    required int cartItemId,
  });
}
