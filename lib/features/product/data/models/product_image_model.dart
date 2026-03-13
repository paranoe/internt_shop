import 'package:diplomeprojectmobile/features/product/domain/entities/product_image.dart';

class ProductImageModel extends ProductImage {
  const ProductImageModel({
    required super.imageId,
    required super.imageUrl,
    super.sortOrder,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      imageId: int.parse((json['image_id'] ?? json['id']).toString()),
      imageUrl: json['image_url']?.toString() ?? '',
      sortOrder: json['sort_order'] == null
          ? null
          : int.tryParse(json['sort_order'].toString()),
    );
  }
}
