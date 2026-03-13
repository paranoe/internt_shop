import 'package:diplomeprojectmobile/features/orders/domain/entities/order.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.orderId,
    required super.pickupPointId,
    required super.totalAmount,
    required super.createdAt,
    required super.status,
    required super.itemsCount,
  });

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: _toInt(json['order_id']),
      pickupPointId: _toInt(json['pickup_point_id']),
      totalAmount: json['total_amount']?.toString() ?? '0',
      createdAt: json['created_at']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      itemsCount: _toInt(json['items_count']),
    );
  }
}
