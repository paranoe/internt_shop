import 'package:diplomeprojectmobile/core/network/api_endpoints.dart';
import 'package:diplomeprojectmobile/core/network/dio_client.dart';

class SellerApi {
  const SellerApi(this._dioClient);

  final DioClient _dioClient;

  List<Map<String, dynamic>> _extractItems(dynamic data) {
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    final map = Map<String, dynamic>.from(data as Map);
    final items = (map['items'] as List<dynamic>? ?? const []);

    return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dioClient.dio.get(ApiEndpoints.sellerProfile);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updateProfile({
    String? shopName,
    String? description,
    String? inn,
    String? unp,
  }) async {
    final response = await _dioClient.dio.patch(
      ApiEndpoints.sellerProfile,
      data: {
        'shop_name': shopName,
        'description': description,
        'inn': inn,
        'unp': unp,
      },
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _dioClient.dio.get(ApiEndpoints.categories);
    return _extractItems(response.data);
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await _dioClient.dio.get(ApiEndpoints.sellerProducts);
    return _extractItems(response.data);
  }

  Future<int?> createProduct({
    required int categoryId,
    required String name,
    String? description,
    required String price,
    required int quantity,
    String currency = 'BYN',
  }) async {
    final response = await _dioClient.dio.post(
      ApiEndpoints.sellerProducts,
      data: {
        'category_id': categoryId,
        'name': name,
        'description': description,
        'price': num.tryParse(price.replaceAll(',', '.')) ?? price,
        'currency': currency,
        'quantity': quantity,
      },
    );

    final data = Map<String, dynamic>.from(response.data as Map);
    return int.tryParse(data['product_id']?.toString() ?? '');
  }

  Future<void> updateProduct({
    required int productId,
    int? categoryId,
    String? name,
    String? description,
    String? price,
    int? quantity,
    String? currency,
  }) async {
    final body = <String, dynamic>{};

    if (categoryId != null) {
      body['category_id'] = categoryId;
    }

    if (name != null) {
      body['name'] = name;
    }

    if (description != null) {
      body['description'] = description;
    }

    if (price != null) {
      body['price'] = num.tryParse(price.replaceAll(',', '.')) ?? price;
    }

    if (quantity != null) {
      body['quantity'] = quantity;
    }

    if (currency != null) {
      body['currency'] = currency;
    }

    await _dioClient.dio.patch(
      '${ApiEndpoints.sellerProducts}/$productId',
      data: body,
    );
  }

  Future<void> deleteProduct(int productId) async {
    await _dioClient.dio.delete('${ApiEndpoints.sellerProducts}/$productId');
  }

  Future<List<Map<String, dynamic>>> getProductImages(int productId) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.products}/$productId/images',
    );

    return _extractItems(response.data);
  }

  Future<void> uploadProductImage({
    required int productId,
    required String imageUrl,
    int sortOrder = 1,
  }) async {
    await _dioClient.dio.post(
      '${ApiEndpoints.sellerProducts}/$productId/images',
      data: {'image_url': imageUrl, 'sort_order': sortOrder},
    );
  }

  Future<void> deleteProductImage({
    required int productId,
    required int imageId,
  }) async {
    await _dioClient.dio.delete(
      '${ApiEndpoints.sellerProducts}/$productId/images',
      queryParameters: {'image_id': imageId},
    );
  }

  Future<List<Map<String, dynamic>>> getProductParameters(int productId) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.products}/$productId/parameters',
    );

    return _extractItems(response.data);
  }

  Future<void> setProductParameters({
    required int productId,
    required List<Map<String, dynamic>> items,
  }) async {
    await _dioClient.dio.put(
      '${ApiEndpoints.sellerProducts}/$productId/parameters',
      data: {'items': items},
    );
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final response = await _dioClient.dio.get(ApiEndpoints.sellerOrders);
    return _extractItems(response.data);
  }

  Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.sellerOrders}/$orderId',
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    await _dioClient.dio.patch(
      '${ApiEndpoints.sellerOrders}/$orderId',
      data: {'status': status},
    );
  }
}
