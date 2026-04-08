class OrderPreviewItem {
  const OrderPreviewItem({
    required this.productId,
    required this.productName,
    this.imageUrl,
  });

  final int productId;
  final String productName;
  final String? imageUrl;
}
