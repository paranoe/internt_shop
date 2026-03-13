import 'package:equatable/equatable.dart';
import 'package:diplomeprojectmobile/features/orders/domain/entities/order.dart';
import 'package:diplomeprojectmobile/features/orders/domain/entities/order_item.dart';

enum OrdersStatus { initial, loading, success, error }

class OrdersState extends Equatable {
  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.selectedOrder,
    this.orderItems = const [],
    this.errorMessage,
  });

  final OrdersStatus status;
  final List<OrderEntity> orders;
  final OrderEntity? selectedOrder;
  final List<OrderItemEntity> orderItems;
  final String? errorMessage;

  OrdersState copyWith({
    OrdersStatus? status,
    List<OrderEntity>? orders,
    OrderEntity? selectedOrder,
    List<OrderItemEntity>? orderItems,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      orderItems: orderItems ?? this.orderItems,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    orders,
    selectedOrder,
    orderItems,
    errorMessage,
  ];
}
