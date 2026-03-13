class ProductDetails {
  const ProductDetails({
    required this.productId,
    required this.name,
    required this.price,
    required this.currency,
    this.description,
    this.categoryId,
    this.sellerId,
    this.mainImage,
  });

  final int productId;
  final String name;
  final String price;
  final String currency;
  final String? description;
  final int? categoryId;
  final int? sellerId;
  final String? mainImage;
}
