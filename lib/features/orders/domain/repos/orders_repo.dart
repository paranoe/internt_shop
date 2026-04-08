import 'package:diplomeprojectmobile/features/orders/domain/entities/order.dart';
import 'package:diplomeprojectmobile/features/orders/domain/entities/order_item.dart';

abstract class OrdersRepo {
  Future<List<Order>> getOrders();

  Future<(Order, List<OrderItemEntity>)> getOrderDetails(int orderId);
}
