import 'package:diplomeprojectmobile/features/cart/domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.cartItemId,
    required super.productId,
    required super.productName,
    required super.price,
    required super.currency,
    required super.quantity,
    required super.selectedForPurchase,
    super.listTypeId,
    super.listTypeName,
    super.status,
    super.addedAt,
    super.mainImage,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartItemId: int.parse(json['cart_item_id'].toString()),
      productId: int.parse(json['product_id'].toString()),
      productName: json['product_name']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      currency: json['currency']?.toString() ?? '',
      quantity: int.parse(json['quantity'].toString()),
      selectedForPurchase: json['selected_for_purchase'] == true,
      listTypeId: json['list_type_id'] == null
          ? null
          : int.tryParse(json['list_type_id'].toString()),
      listTypeName: json['list_type_name']?.toString(),
      status: json['status']?.toString(),
      addedAt: json['added_at']?.toString(),
      mainImage: json['main_image']?.toString(),
    );
  }
}
