import 'package:diplomeprojectmobile/core/network/api_endpoints.dart';
import 'package:diplomeprojectmobile/core/network/dio_client.dart';

import '../models/category_model.dart';
import '../models/product_card_model.dart';

class CatalogApi {
  const CatalogApi(this._dioClient);

  final DioClient _dioClient;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dioClient.dio.get(ApiEndpoints.categories);

    final data = Map<String, dynamic>.from(response.data as Map);
    final items = (data['items'] as List<dynamic>? ?? []);

    return items
        .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<ProductCardModel>> getProductsByCategory({
    int? categoryId,
  }) async {
    final query = <String, dynamic>{};

    if (categoryId != null) {
      query['category_id'] = categoryId;
    }

    final response = await _dioClient.dio.get(
      ApiEndpoints.products,
      queryParameters: query,
    );

    final data = Map<String, dynamic>.from(response.data as Map);
    final items = (data['items'] as List<dynamic>? ?? []);

    return items
        .map(
          (e) => ProductCardModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  Future<List<ProductCardModel>> searchProducts({required String query}) async {
    final response = await _dioClient.dio.get(
      ApiEndpoints.products,
      queryParameters: {'q': query},
    );

    final data = Map<String, dynamic>.from(response.data as Map);
    final items = (data['items'] as List<dynamic>? ?? []);

    return items
        .map(
          (e) => ProductCardModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }
}
