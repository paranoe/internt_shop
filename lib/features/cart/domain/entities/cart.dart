import 'cart_item.dart';

class Cart {
  const Cart({
    required this.cartId,
    required this.userId,
    required this.totalSelectedAmount,
    required this.items,
  });

  final int cartId;
  final int userId;
  final String totalSelectedAmount;
  final List<CartItem> items;
}
