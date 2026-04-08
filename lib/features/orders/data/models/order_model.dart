import 'package:diplomeprojectmobile/features/orders/domain/entities/order.dart';
import 'package:diplomeprojectmobile/features/orders/data/models/order_preview_item_model.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.orderId,
    required super.pickupPointId,
    required super.totalAmount,
    required super.createdAt,
    required super.status,
    required super.itemsCount,
    super.previewItems = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawPreviewItems =
        (json['preview_items'] as List<dynamic>? ?? const []);

    return OrderModel(
      orderId: int.tryParse(json['order_id'].toString()) ?? 0,
      pickupPointId: int.tryParse(json['pickup_point_id'].toString()) ?? 0,
      totalAmount: json['total_amount']?.toString() ?? '0',
      createdAt: json['created_at']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      itemsCount: int.tryParse(json['items_count'].toString()) ?? 0,
      previewItems: rawPreviewItems
          .map(
            (e) => OrderPreviewItemModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }
}
