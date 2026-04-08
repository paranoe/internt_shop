import 'package:diplomeprojectmobile/features/orders/domain/entities/order_preview_item.dart';

class OrderPreviewItemModel extends OrderPreviewItem {
  const OrderPreviewItemModel({
    required super.productId,
    required super.productName,
    super.imageUrl,
  });

  factory OrderPreviewItemModel.fromJson(Map<String, dynamic> json) {
    return OrderPreviewItemModel(
      productId: int.tryParse(json['product_id'].toString()) ?? 0,
      productName: json['product_name']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
    );
  }
}
