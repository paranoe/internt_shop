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
  });

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      orderItemId: _toInt(json['order_item_id']),
      quantity: _toInt(json['quantity']),
      priceSnapshot: json['price_snapshot']?.toString() ?? '0',
      lineTotal: json['line_total']?.toString() ?? '0',
      sourceCartItemId: _toNullableInt(json['source_cart_item_id']),
      productId: _toInt(json['product_id']),
      productName: json['product_name']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
    );
  }
}
