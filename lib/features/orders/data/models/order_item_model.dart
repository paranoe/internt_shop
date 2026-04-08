import 'package:diplomeprojectmobile/features/orders/domain/entities/order_item.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.orderItemId,
    required super.quantity,
    required super.priceSnapshot,
    required super.lineTotal,
    super.sourceCartItemId,
    required super.productId,
    required super.productName,
    required super.currency,
    super.imageUrl,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final price = json['price_snapshot']?.toString() ?? '0';
    final quantity = int.tryParse(json['quantity'].toString()) ?? 0;
    final parsedPrice = double.tryParse(price) ?? 0;
    final lineTotal = (parsedPrice * quantity).toStringAsFixed(2);

    return OrderItemModel(
      orderItemId: int.tryParse(json['order_item_id'].toString()) ?? 0,
      quantity: quantity,
      priceSnapshot: price,
      lineTotal: lineTotal,
      sourceCartItemId: json['source_cart_item_id'] == null
          ? null
          : int.tryParse(json['source_cart_item_id'].toString()),
      productId: int.tryParse(json['product_id'].toString()) ?? 0,
      productName: json['product_name']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
    );
  }
}
