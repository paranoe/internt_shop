class OrderEntity {
  const OrderEntity({
    required this.orderId,
    required this.pickupPointId,
    required this.totalAmount,
    required this.createdAt,
    required this.status,
    required this.itemsCount,
  });

  final int orderId;
  final int pickupPointId;
  final String totalAmount;
  final String createdAt;
  final String status;
  final int itemsCount;
}
