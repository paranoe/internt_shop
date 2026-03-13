class CheckoutPreviewItem {
  const CheckoutPreviewItem({
    required this.cartItemId,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.lineTotal,
  });

  final int cartItemId;
  final int productId;
  final String name;
  final String price;
  final int quantity;
  final String lineTotal;
}

class CheckoutPreview {
  const CheckoutPreview({
    required this.cartId,
    required this.currency,
    required this.items,
    required this.totalAmount,
  });

  final int cartId;
  final String currency;
  final List<CheckoutPreviewItem> items;
  final String totalAmount;
}
