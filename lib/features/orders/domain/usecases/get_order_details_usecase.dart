import 'package:diplomeprojectmobile/features/orders/domain/entities/order.dart';
import 'package:diplomeprojectmobile/features/orders/domain/entities/order_item.dart';
import 'package:diplomeprojectmobile/features/orders/domain/repos/orders_repo.dart';

class GetOrderDetailsUseCase {
  const GetOrderDetailsUseCase(this._repo);

  final OrdersRepo _repo;

  Future<(OrderEntity, List<OrderItemEntity>)> call(int orderId) {
    return _repo.getOrderDetails(orderId);
  }
}
