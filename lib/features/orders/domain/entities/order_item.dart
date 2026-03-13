class OrderItemEntity {
  const OrderItemEntity({
    required this.orderItemId,
    required this.quantity,
    required this.priceSnapshot,
    required this.lineTotal,
    this.sourceCartItemId,
    required this.productId,
    required this.productName,
    required this.currency,
  });

  final int orderItemId;
  final int quantity;
  final String priceSnapshot;
  final String lineTotal;
  final int? sourceCartItemId;
  final int productId;
  final String productName;
  final String currency;
}
