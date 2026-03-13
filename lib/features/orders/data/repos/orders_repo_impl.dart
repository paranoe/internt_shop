import 'package:diplomeprojectmobile/features/orders/data/datasources/orders_api.dart';
import 'package:diplomeprojectmobile/features/orders/domain/entities/order.dart';
import 'package:diplomeprojectmobile/features/orders/domain/entities/order_item.dart';
import 'package:diplomeprojectmobile/features/orders/domain/repos/orders_repo.dart';

class OrdersRepoImpl implements OrdersRepo {
  const OrdersRepoImpl(this._api);

  final OrdersApi _api;

  @override
  Future<List<OrderEntity>> getOrders() => _api.getOrders();

  @override
  Future<(OrderEntity, List<OrderItemEntity>)> getOrderDetails(int orderId) {
    return _api.getOrderDetails(orderId);
  }
}
