import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:diplomeprojectmobile/features/orders/data/datasources/orders_api.dart';
import 'package:diplomeprojectmobile/features/orders/data/repos/orders_repo_impl.dart';
import 'package:diplomeprojectmobile/features/orders/domain/usecases/get_order_details_usecase.dart';
import 'package:diplomeprojectmobile/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:diplomeprojectmobile/features/orders/presentation/controllers/orders_state.dart';

class OrdersController extends Cubit<OrdersState> {
  OrdersController({required OrdersApi ordersApi})
    : _getOrdersUseCase = GetOrdersUseCase(OrdersRepoImpl(ordersApi)),
      _getOrderDetailsUseCase = GetOrderDetailsUseCase(
        OrdersRepoImpl(ordersApi),
      ),
      super(const OrdersState());

  final GetOrdersUseCase _getOrdersUseCase;
  final GetOrderDetailsUseCase _getOrderDetailsUseCase;

  Future<void> loadOrders() async {
    emit(state.copyWith(status: OrdersStatus.loading, clearError: true));

    try {
      final orders = await _getOrdersUseCase();
      emit(
        state.copyWith(
          status: OrdersStatus.success,
          orders: orders,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: OrdersStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> loadOrderDetails(int orderId) async {
    emit(state.copyWith(status: OrdersStatus.loading, clearError: true));

    try {
      final result = await _getOrderDetailsUseCase(orderId);
      final order = result.$1;
      final items = result.$2;

      emit(
        state.copyWith(
          status: OrdersStatus.success,
          selectedOrder: order,
          orderItems: items,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: OrdersStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
