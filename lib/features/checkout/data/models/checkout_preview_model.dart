import 'package:diplomeprojectmobile/features/checkout/domain/entities/checkout_preview.dart';

class CheckoutPreviewItemModel extends CheckoutPreviewItem {
  const CheckoutPreviewItemModel({
    required super.cartItemId,
    required super.productId,
    required super.name,
    required super.price,
    required super.quantity,
    required super.lineTotal,
  });

  factory CheckoutPreviewItemModel.fromJson(Map<String, dynamic> json) {
    return CheckoutPreviewItemModel(
      cartItemId: int.parse(json['cart_item_id'].toString()),
      productId: int.parse(json['product_id'].toString()),
      name: json['name']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      quantity: int.parse(json['quantity'].toString()),
      lineTotal: json['line_total']?.toString() ?? '0',
    );
  }
}

class CheckoutPreviewModel extends CheckoutPreview {
  const CheckoutPreviewModel({
    required super.cartId,
    required super.currency,
    required super.items,
    required super.totalAmount,
  });

  factory CheckoutPreviewModel.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? []);

    return CheckoutPreviewModel(
      cartId: int.parse(json['cart_id'].toString()),
      currency: json['currency']?.toString() ?? '',
      items: rawItems
          .map(
            (e) => CheckoutPreviewItemModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      totalAmount: json['total_amount']?.toString() ?? '0',
    );
  }
}
