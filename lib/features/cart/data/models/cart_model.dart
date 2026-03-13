import 'package:diplomeprojectmobile/features/cart/domain/entities/cart.dart';

import 'cart_item_model.dart';

class CartModel extends Cart {
  const CartModel({
    required super.cartId,
    required super.userId,
    required super.totalSelectedAmount,
    required super.items,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? []);

    return CartModel(
      cartId: int.parse(json['cart_id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      totalSelectedAmount: json['total_selected_amount']?.toString() ?? '0',
      items: rawItems
          .map((e) => CartItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
