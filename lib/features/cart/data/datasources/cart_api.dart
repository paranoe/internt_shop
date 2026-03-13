import 'package:diplomeprojectmobile/core/network/api_endpoints.dart';
import 'package:diplomeprojectmobile/core/network/dio_client.dart';

import '../models/cart_model.dart';

class CartApi {
  const CartApi(this._dioClient);

  final DioClient _dioClient;

  Future<CartModel> getCart() async {
    final response = await _dioClient.dio.get(ApiEndpoints.cart);

    return CartModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<void> addCartItem({
    required int productId,
    required int quantity,
  }) async {
    await _dioClient.dio.post(
      '${ApiEndpoints.cart}/items',
      data: {'product_id': productId, 'quantity': quantity},
    );
  }

  Future<void> updateCartItem({
    required int cartItemId,
    int? quantity,
    bool? selectedForPurchase,
  }) async {
    final body = <String, dynamic>{};

    if (quantity != null) body['quantity'] = quantity;
    if (selectedForPurchase != null) {
      body['selected_for_purchase'] = selectedForPurchase;
    }

    await _dioClient.dio.patch(
      '${ApiEndpoints.cart}/items/$cartItemId',
      data: body,
    );
  }

  Future<void> deleteCartItem({required int cartItemId}) async {
    await _dioClient.dio.delete('${ApiEndpoints.cart}/items/$cartItemId');
  }
}
