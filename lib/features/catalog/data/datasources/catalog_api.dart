import 'package:diplomeprojectmobile/core/network/api_endpoints.dart';
import 'package:diplomeprojectmobile/core/network/dio_client.dart';

import '../models/category_model.dart';
import '../models/product_card_model.dart';
import '../models/subcategory_model.dart';

class CatalogApi {
  const CatalogApi(this._dioClient);

  final DioClient _dioClient;

  List<dynamic> _extractItems(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    return map['items'] as List<dynamic>? ?? [];
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dioClient.dio.get(ApiEndpoints.categories);
    final items = _extractItems(response.data);

    return items
        .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<SubcategoryModel>> getSubcategories(int categoryId) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.categories}/$categoryId/subcategories',
    );

    final items = _extractItems(response.data);

    return items
        .map(
          (e) => SubcategoryModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> getSubcategoryFilters(
    int subcategoryId,
  ) async {
    final response = await _dioClient.dio.get(
      '/subcategories/$subcategoryId/filters',
    );

    final items = _extractItems(response.data);
    return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<ProductCardModel>> getProducts({
    int? categoryId,
    int? subcategoryId,
    String? searchQuery,
    String? minPrice,
    String? maxPrice,
    double? minRating,
    String? sortBy,
    Map<int, String> parameterFilters = const {},
  }) async {
    final query = <String, dynamic>{};

    if (categoryId != null) query['category_id'] = categoryId;
    if (subcategoryId != null) query['subcategory_id'] = subcategoryId;
    if ((searchQuery ?? '').trim().isNotEmpty) query['q'] = searchQuery!.trim();
    if ((minPrice ?? '').trim().isNotEmpty)
      query['min_price'] = minPrice!.trim();
    if ((maxPrice ?? '').trim().isNotEmpty)
      query['max_price'] = maxPrice!.trim();
    if (minRating != null && minRating > 0) query['min_rating'] = minRating;
    if ((sortBy ?? '').trim().isNotEmpty) query['sort_by'] = sortBy;

    for (final entry in parameterFilters.entries) {
      if (entry.value.trim().isEmpty) continue;
      query['param_${entry.key}'] = entry.value.trim();
    }

    final response = await _dioClient.dio.get(
      ApiEndpoints.products,
      queryParameters: query,
    );

    final items = _extractItems(response.data);

    return items
        .map(
          (e) => ProductCardModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  Future<Map<String, dynamic>> getSearchFilters(String query) async {
    final response = await _dioClient.dio.get(
      '/products/search_filters',
      queryParameters: {'q': query},
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<ProductCardModel>> getProductsByCategory({
    int? categoryId,
    int? subcategoryId,
  }) async {
    return getProducts(categoryId: categoryId, subcategoryId: subcategoryId);
  }

  Future<List<ProductCardModel>> searchProducts({required String query}) async {
    return getProducts(searchQuery: query);
  }
}
