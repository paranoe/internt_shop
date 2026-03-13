import 'package:diplomeprojectmobile/features/catalog/domain/entities/product_card.dart';

class ProductCardModel extends ProductCardEntity {
  const ProductCardModel({
    required super.productId,
    required super.name,
    required super.price,
    required super.currency,
    super.mainImage,
    super.categoryId,
  });

  factory ProductCardModel.fromJson(Map<String, dynamic> json) {
    return ProductCardModel(
      productId: int.parse(json['product_id'].toString()),
      name: json['name']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      mainImage: json['main_image']?.toString(),
      categoryId: json['category_id'] == null
          ? null
          : int.tryParse(json['category_id'].toString()),
    );
  }
}
