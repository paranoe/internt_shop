import 'package:diplomeprojectmobile/core/network/api_endpoints.dart';
import 'package:diplomeprojectmobile/core/network/dio_client.dart';
import 'package:diplomeprojectmobile/features/cart/data/models/cart_item_model.dart';

class FavoritesApi {
  const FavoritesApi(this._dioClient);

  final DioClient _dioClient;

  Future<List<CartItemModel>> getFavorites() async {
    final response = await _dioClient.dio.get(ApiEndpoints.favorites);
    final data = Map<String, dynamic>.from(response.data as Map);
    final items = (data['items'] as List<dynamic>? ?? const []);

    return items
        .map((e) => CartItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> addFavorite(int productId) async {
    await _dioClient.dio.post(
      ApiEndpoints.favorites,
      data: {'product_id': productId},
    );
  }

  Future<void> deleteFavorite(int productId) async {
    await _dioClient.dio.delete('${ApiEndpoints.favorites}/$productId');
  }
}
