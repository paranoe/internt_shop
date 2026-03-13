class ProductCardEntity {
  const ProductCardEntity({
    required this.productId,
    required this.name,
    required this.price,
    required this.currency,
    this.mainImage,
    this.categoryId,
  });

  final int productId;
  final String name;
  final String price;
  final String currency;
  final String? mainImage;
  final int? categoryId;
}
