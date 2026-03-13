import 'package:diplomeprojectmobile/core/network/api_endpoints.dart';
import 'package:diplomeprojectmobile/core/network/dio_client.dart';
import 'package:diplomeprojectmobile/features/orders/data/models/order_item_model.dart';
import 'package:diplomeprojectmobile/features/orders/data/models/order_model.dart';

class OrdersApi {
  const OrdersApi(this._dioClient);

  final DioClient _dioClient;

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }

  Future<List<OrderModel>> getOrders() async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.orders,
      queryParameters: {'page': 1, 'limit': 50},
    );

    final data = Map<String, dynamic>.from(response.data as Map);
    final items = (data['items'] as List<dynamic>? ?? []);

    return items
        .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<(OrderModel, List<OrderItemModel>)> getOrderDetails(
    int orderId,
  ) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.orders}/$orderId',
    );

    final data = Map<String, dynamic>.from(response.data as Map);
    final orderJson = Map<String, dynamic>.from(data['order'] as Map);
    final itemsJson = (data['items'] as List<dynamic>? ?? []);

    final order = OrderModel(
      orderId: _toInt(orderJson['order_id']),
      pickupPointId: _toInt(orderJson['pickup_point_id']),
      totalAmount: orderJson['total_amount']?.toString() ?? '0',
      createdAt: orderJson['created_at']?.toString() ?? '',
      status: orderJson['status']?.toString() ?? '',
      itemsCount: itemsJson.length,
    );

    final items = itemsJson
        .map(
          (e) => OrderItemModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();

    return (order, items);
  }
}
