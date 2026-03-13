import 'package:diplomeprojectmobile/features/orders/domain/entities/order.dart';
import 'package:diplomeprojectmobile/features/orders/domain/repos/orders_repo.dart';

class GetOrdersUseCase {
  const GetOrdersUseCase(this._repo);

  final OrdersRepo _repo;

  Future<List<OrderEntity>> call() => _repo.getOrders();
}
