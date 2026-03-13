import 'package:diplomeprojectmobile/features/product/domain/entities/product_details.dart';

class ProductDetailsModel extends ProductDetails {
  const ProductDetailsModel({
    required super.productId,
    required super.name,
    required super.price,
    required super.currency,
    super.description,
    super.categoryId,
    super.sellerId,
    super.mainImage,
  });

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailsModel(
      productId: int.parse(json['product_id'].toString()),
      name: json['name']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      description: json['description']?.toString(),
      categoryId: json['category_id'] == null
          ? null
          : int.tryParse(json['category_id'].toString()),
      sellerId: json['seller_id'] == null
          ? null
          : int.tryParse(json['seller_id'].toString()),
      mainImage: json['main_image']?.toString(),
    );
  }
}
