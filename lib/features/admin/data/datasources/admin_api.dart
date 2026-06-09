import 'package:diplomeprojectmobile/core/network/dio_client.dart';

class AdminApi {
  const AdminApi(this._dioClient);

  final DioClient _dioClient;

  List<Map<String, dynamic>> _extractItems(dynamic data) {
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    final map = Map<String, dynamic>.from(data as Map);
    final items = (map['items'] as List<dynamic>? ?? const []);

    return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _dioClient.dio.get('/categories');
    return _extractItems(response.data);
  }

  Future<List<Map<String, dynamic>>> getSubcategoriesByCategory(
    int categoryId,
  ) async {
    final response = await _dioClient.dio.get(
      '/categories/$categoryId/subcategories',
    );
    return _extractItems(response.data);
  }

  Future<List<Map<String, dynamic>>> getParameters() async {
    final response = await _dioClient.dio.get('/admin/parameters');
    return _extractItems(response.data);
  }

  Future<void> createParameter({
    required String name,
    required String dataType,
    int? unitId,
  }) async {
    await _dioClient.dio.post(
      '/admin/parameters',
      data: {'name': name, 'data_type': dataType, 'unit_id': unitId},
    );
  }

  Future<void> deleteParameter(int parameterId) async {
    await _dioClient.dio.delete('/admin/parameters/$parameterId');
  }

  Future<List<Map<String, dynamic>>> getSubcategoryParameterBindings() async {
    final response = await _dioClient.dio.get('/admin/subcategory-parameters');
    return _extractItems(response.data);
  }

  Future<void> createSubcategoryParameterBinding({
    required int subcategoryId,
    required int parameterId,
    required bool isRequired,
  }) async {
    await _dioClient.dio.post(
      '/admin/subcategory-parameters',
      data: {
        'subcategory_id': subcategoryId,
        'parameter_id': parameterId,
        'is_required': isRequired,
      },
    );
  }

  Future<void> deleteSubcategoryParameterBinding({
    required int subcategoryId,
    required int parameterId,
  }) async {
    await _dioClient.dio.delete(
      '/admin/subcategory-parameters/$subcategoryId',
      queryParameters: {'parameter_id': parameterId},
    );
  }

  Future<List<Map<String, dynamic>>> getSubcategoryParametersForProduct(
    int subcategoryId,
  ) async {
    final response = await _dioClient.dio.get(
      '/subcategories/$subcategoryId/parameters',
    );
    return _extractItems(response.data);
  }

  Future<List<Map<String, dynamic>>> getOrders({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dioClient.dio.get(
      '/admin/orders',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null && status.trim().isNotEmpty) 'status': status,
      },
    );

    return _extractItems(response.data);
  }

  Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    final response = await _dioClient.dio.get('/admin/orders/$orderId');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    await _dioClient.dio.patch(
      '/admin/orders/$orderId',
      data: {'status': status},
    );
  }

  Future<List<Map<String, dynamic>>> getCities({String? query}) async {
    final response = await _dioClient.dio.get(
      '/admin/cities',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      },
    );

    return _extractItems(response.data);
  }

  Future<void> createCity({required String cityName}) async {
    await _dioClient.dio.post('/admin/cities', data: {'city_name': cityName});
  }

  Future<void> updateCity({
    required int cityId,
    required String cityName,
  }) async {
    await _dioClient.dio.patch(
      '/admin/cities/$cityId',
      data: {'city_name': cityName},
    );
  }

  Future<void> deleteCity(int cityId) async {
    await _dioClient.dio.delete('/admin/cities/$cityId');
  }

  Future<List<Map<String, dynamic>>> getPickupPoints({int? cityId}) async {
    final response = await _dioClient.dio.get(
      '/admin/pickup-points',
      queryParameters: {if (cityId != null && cityId > 0) 'city_id': cityId},
    );

    return _extractItems(response.data);
  }

  Future<void> createPickupPoint({required int houseId}) async {
    await _dioClient.dio.post(
      '/admin/pickup-points',
      data: {'house_id': houseId},
    );
  }

  Future<void> updatePickupPoint({
    required int pickupPointId,
    required int houseId,
  }) async {
    await _dioClient.dio.patch(
      '/admin/pickup-points/$pickupPointId',
      data: {'house_id': houseId},
    );
  }

  Future<void> deletePickupPoint(int pickupPointId) async {
    await _dioClient.dio.delete('/admin/pickup-points/$pickupPointId');
  }

  Future<List<Map<String, dynamic>>> getProducts({
    String? query,
    int? categoryId,
    int? subcategoryId,
    int? sellerId,
  }) async {
    final response = await _dioClient.dio.get(
      '/admin/products',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (categoryId != null && categoryId > 0) 'category_id': categoryId,
        if (subcategoryId != null && subcategoryId > 0)
          'subcategory_id': subcategoryId,
        if (sellerId != null && sellerId > 0) 'seller_id': sellerId,
      },
    );

    return _extractItems(response.data);
  }

  Future<Map<String, dynamic>> getProductDetails(int productId) async {
    final response = await _dioClient.dio.get('/admin/products/$productId');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> createProduct({
    required int categoryId,
    required int sellerId,
    required int subcategoryId,
    required String name,
    String? description,
    required String price,
    required int quantity,
    String currency = 'BYN',
    List<Map<String, dynamic>> parameterValues = const [],
  }) async {
    await _dioClient.dio.post(
      '/admin/products',
      data: {
        'category_id': categoryId,
        'seller_id': sellerId,
        'subcategory_id': subcategoryId,
        'name': name,
        'description': description,
        'price': num.tryParse(price.replaceAll(',', '.')) ?? price,
        'quantity': quantity,
        'currency': currency,
        'parameter_values': parameterValues,
      },
    );
  }

  Future<void> updateProduct({
    required int productId,
    int? categoryId,
    int? sellerId,
    int? subcategoryId,
    String? name,
    String? description,
    String? price,
    int? quantity,
    String? currency,
    List<Map<String, dynamic>>? parameterValues,
  }) async {
    final body = <String, dynamic>{};

    if (categoryId != null) body['category_id'] = categoryId;
    if (sellerId != null) body['seller_id'] = sellerId;
    if (subcategoryId != null) body['subcategory_id'] = subcategoryId;
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (price != null) {
      body['price'] = num.tryParse(price.replaceAll(',', '.')) ?? price;
    }
    if (quantity != null) body['quantity'] = quantity;
    if (currency != null) body['currency'] = currency;
    if (parameterValues != null) body['parameter_values'] = parameterValues;

    await _dioClient.dio.patch('/admin/products/$productId', data: body);
  }

  Future<void> deleteProduct(int productId) async {
    await _dioClient.dio.delete('/admin/products/$productId');
  }

  Future<List<Map<String, dynamic>>> getSellers({String? query}) async {
    final response = await _dioClient.dio.get(
      '/admin/sellers',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      },
    );

    return _extractItems(response.data);
  }

  Future<Map<String, dynamic>> getSellerDetails(int sellerId) async {
    final response = await _dioClient.dio.get('/admin/sellers/$sellerId');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> createSeller({
    required String shopName,
    String? description,
    String? inn,
    String? unp,
    required int userId,
  }) async {
    await _dioClient.dio.post(
      '/admin/sellers',
      data: {
        'shop_name': shopName,
        'description': description,
        'inn': inn,
        'unp': unp,
        'user_id': userId,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getUsers({
    String? query,
    String? role,
    bool? isBlocked,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dioClient.dio.get(
      '/admin/users',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (role != null && role.trim().isNotEmpty) 'role': role.trim(),
        if (isBlocked != null) 'blocked': isBlocked.toString(),
      },
    );

    return _extractItems(response.data);
  }

  Future<List<Map<String, dynamic>>> getReviews({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dioClient.dio.get(
      '/admin/reviews',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null && status.trim().isNotEmpty) 'status': status,
      },
    );

    return _extractItems(response.data);
  }

  Future<void> updateReviewModerationStatus({
    required int reviewId,
    required String moderationStatus,
  }) async {
    await _dioClient.dio.patch(
      '/admin/reviews/$reviewId',
      data: {'moderation_status': moderationStatus},
    );
  }

  Future<void> updateUser({
    required int userId,
    String? firstName,
    String? lastName,
    String? patronymic,
    String? phone,
    String? gender,
    String? role,
    bool? isBlocked,
  }) async {
    final body = <String, dynamic>{};

    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;
    if (patronymic != null) body['patronymic'] = patronymic;
    if (phone != null) body['phone'] = phone;
    if (gender != null) body['gender'] = gender;
    if (role != null) body['role'] = role;
    if (isBlocked != null) body['is_blocked'] = isBlocked;

    await _dioClient.dio.patch('/admin/users/$userId', data: body);
  }

  Future<void> deleteUser(int userId) async {
    await _dioClient.dio.delete('/admin/users/$userId');
  }

  Future<void> updateSeller({
    required int sellerId,
    String? shopName,
    String? description,
    String? inn,
    String? unp,
    int? userId,
  }) async {
    final body = <String, dynamic>{};

    if (shopName != null) body['shop_name'] = shopName;
    if (description != null) body['description'] = description;
    if (inn != null) body['inn'] = inn;
    if (unp != null) body['unp'] = unp;
    if (userId != null) body['user_id'] = userId;

    await _dioClient.dio.patch('/admin/sellers/$sellerId', data: body);
  }

  Future<void> deleteSeller(int sellerId) async {
    await _dioClient.dio.delete('/admin/sellers/$sellerId');
  }

  Future<void> createCategory({required String categoryName}) async {
    await _dioClient.dio.post(
      '/admin/categories',
      data: {'category_name': categoryName},
    );
  }

  Future<void> updateCategory({
    required int categoryId,
    required String categoryName,
  }) async {
    await _dioClient.dio.patch(
      '/admin/categories/$categoryId',
      data: {'category_name': categoryName},
    );
  }

  Future<void> deleteCategory(int categoryId) async {
    await _dioClient.dio.delete('/admin/categories/$categoryId');
  }

  Future<List<Map<String, dynamic>>> getSubcategories({
    String? query,
    int? categoryId,
  }) async {
    final response = await _dioClient.dio.get(
      '/admin/podcategories',
      queryParameters: {
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (categoryId != null && categoryId > 0) 'category_id': categoryId,
      },
    );

    return _extractItems(response.data);
  }

  Future<void> createSubcategory({
    required String name,
    required int categoryId,
  }) async {
    await _dioClient.dio.post(
      '/admin/podcategories',
      data: {'name': name, 'category_id': categoryId},
    );
  }

  Future<void> updateSubcategory({
    required int subcategoryId,
    String? name,
    int? categoryId,
  }) async {
    final body = <String, dynamic>{};

    if (name != null) body['name'] = name;
    if (categoryId != null) body['category_id'] = categoryId;

    await _dioClient.dio.patch(
      '/admin/podcategories/$subcategoryId',
      data: body,
    );
  }

  Future<void> deleteSubcategory(int subcategoryId) async {
    await _dioClient.dio.delete('/admin/podcategories/$subcategoryId');
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await _dioClient.dio.get('/admin/stats');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<Map<String, dynamic>>> getMeasurementUnits() async {
    final response = await _dioClient.dio.get('/admin/measurement-units');
    return _extractItems(response.data);
  }

  Future<List<Map<String, dynamic>>> getStreets({required int cityId}) async {
    final response = await _dioClient.dio.get(
      '/admin/streets',
      queryParameters: {'city_id': cityId},
    );

    return _extractItems(response.data);
  }

  Future<void> createStreet({
    required int cityId,
    required String streetName,
  }) async {
    await _dioClient.dio.post(
      '/admin/streets',
      data: {'city_id': cityId, 'street_name': streetName},
    );
  }

  Future<List<Map<String, dynamic>>> getHouses({required int streetId}) async {
    final response = await _dioClient.dio.get(
      '/admin/houses',
      queryParameters: {'street_id': streetId},
    );

    return _extractItems(response.data);
  }

  Future<void> createHouse({
    required int streetId,
    required String houseNumber,
  }) async {
    await _dioClient.dio.post(
      '/admin/houses',
      data: {'street_id': streetId, 'house_number': houseNumber},
    );
  }

  Future<void> createMeasurementUnit({
    required String name,
    required String shortName,
  }) async {
    await _dioClient.dio.post(
      '/admin/measurement-units',
      data: {'name': name, 'short_name': shortName},
    );
  }

  Future<void> deleteMeasurementUnit(int unitId) async {
    await _dioClient.dio.delete('/admin/measurement-units/$unitId');
  }
}
