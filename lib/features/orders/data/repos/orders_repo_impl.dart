import 'package:diplomeprojectmobile/features/orders/data/datasources/orders_api.dart';
import 'package:diplomeprojectmobile/features/orders/domain/entities/order.dart';
import 'package:diplomeprojectmobile/features/orders/domain/entities/order_item.dart';
import 'package:diplomeprojectmobile/features/orders/domain/repos/orders_repo.dart';

class OrdersRepoImpl implements OrdersRepo {
  const OrdersRepoImpl(this._api);

  final OrdersApi _api;

  @override
  Future<List<Order>> getOrders() async {
    final result = await _api.getOrders();
    return result;
  }

  @override
  Future<(Order, List<OrderItemEntity>)> getOrderDetails(int orderId) async {
    final result = await _api.getOrderDetails(orderId);
    return result;
  }
}
