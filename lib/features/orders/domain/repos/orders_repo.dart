import 'package:diplomeprojectmobile/features/orders/domain/entities/order.dart';
import 'package:diplomeprojectmobile/features/orders/domain/entities/order_item.dart';

abstract class OrdersRepo {
  Future<List<OrderEntity>> getOrders();
  Future<(OrderEntity, List<OrderItemEntity>)> getOrderDetails(int orderId);
}
