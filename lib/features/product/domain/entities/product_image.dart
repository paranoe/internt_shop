class ProductImage {
  const ProductImage({
    required this.imageId,
    required this.imageUrl,
    this.sortOrder,
  });

  final int imageId;
  final String imageUrl;
  final int? sortOrder;
}
