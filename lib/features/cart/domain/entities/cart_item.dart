class CartItem {
  const CartItem({
    required this.cartItemId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.currency,
    required this.quantity,
    required this.selectedForPurchase,
    this.listTypeId,
    this.listTypeName,
    this.status,
    this.addedAt,
    this.mainImage,
  });

  final int cartItemId;
  final int productId;
  final String productName;
  final String price;
  final String currency;
  final int quantity;
  final bool selectedForPurchase;
  final int? listTypeId;
  final String? listTypeName;
  final String? status;
  final String? addedAt;
  final String? mainImage;
}
