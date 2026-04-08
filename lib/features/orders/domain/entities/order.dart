import 'package:diplomeprojectmobile/features/orders/domain/entities/order_preview_item.dart';

class Order {
  const Order({
    required this.orderId,
    required this.pickupPointId,
    required this.totalAmount,
    required this.createdAt,
    required this.status,
    required this.itemsCount,
    this.previewItems = const [],
  });

  final int orderId;
  final int pickupPointId;
  final String totalAmount;
  final String createdAt;
  final String status;
  final int itemsCount;
  final List<OrderPreviewItem> previewItems;
}
