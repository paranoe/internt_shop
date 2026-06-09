import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:diplomeprojectmobile/features/admin/data/datasources/admin_api.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_state.dart';

class AdminController extends Cubit<AdminState> {
  AdminController({required AdminApi adminApi})
    : _adminApi = adminApi,
      super(const AdminState());

  final AdminApi _adminApi;

  Future<void> loadAll() async {
    emit(state.copyWith(status: AdminStatus.loading, clearError: true));

    try {
      final parameters = await _adminApi.getParameters();
      final categories = await _adminApi.getCategories();
      final bindings = await _adminApi.getSubcategoryParameterBindings();
      final measurementUnits = await _adminApi.getMeasurementUnits();

      emit(
        state.copyWith(
          status: AdminStatus.success,
          parameters: parameters,
          categories: categories,
          bindings: bindings,
          measurementUnits: measurementUnits,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> loadSubcategoriesByCategory(int categoryId) async {
    try {
      final subcategories = await _adminApi.getSubcategories(
        categoryId: categoryId,
      );

      emit(state.copyWith(subcategories: subcategories, clearError: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<bool> createParameter({
    required String name,
    required String dataType,
    int? unitId,
  }) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.createParameter(
        name: name,
        dataType: dataType,
        unitId: unitId,
      );
      await loadAll();
      return true;
    } catch (e) {
      final message = e.toString().contains('409')
          ? 'Параметр с таким названием уже существует'
          : e.toString();

      emit(state.copyWith(status: AdminStatus.error, errorMessage: message));
      return false;
    }
  }

  Future<bool> deleteParameter(int parameterId) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.deleteParameter(parameterId);
      await loadAll();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<void> loadProductParametersBySubcategory(int subcategoryId) async {
    try {
      final items = await _adminApi.getSubcategoryParametersForProduct(
        subcategoryId,
      );

      emit(state.copyWith(productParameters: items, clearError: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<bool> createBinding({
    required int subcategoryId,
    required int parameterId,
    required bool isRequired,
  }) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.createSubcategoryParameterBinding(
        subcategoryId: subcategoryId,
        parameterId: parameterId,
        isRequired: isRequired,
      );
      await loadAll();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<bool> deleteBinding({
    required int subcategoryId,
    required int parameterId,
  }) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.deleteSubcategoryParameterBinding(
        subcategoryId: subcategoryId,
        parameterId: parameterId,
      );
      await loadAll();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<void> loadOrders({String? status}) async {
    emit(state.copyWith(status: AdminStatus.loading, clearError: true));

    try {
      final orders = await _adminApi.getOrders(status: status);

      emit(
        state.copyWith(
          status: AdminStatus.success,
          orders: orders,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> loadOrderDetails(int orderId) async {
    emit(
      state.copyWith(
        status: AdminStatus.loading,
        clearError: true,
        clearSelectedOrder: true,
      ),
    );

    try {
      final data = await _adminApi.getOrderDetails(orderId);
      final order = Map<String, dynamic>.from(
        data['order'] as Map? ?? const {},
      );
      final items = (data['items'] as List? ?? const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      emit(
        state.copyWith(
          status: AdminStatus.success,
          selectedOrder: order,
          selectedOrderItems: items,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<bool> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.updateOrderStatus(orderId: orderId, status: status);
      await loadOrderDetails(orderId);
      await loadOrders();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<bool> confirmOrderPayment(int orderId) async {
    return updateOrderStatus(orderId: orderId, status: 'paid');
  }

  Future<void> loadCities({String? query}) async {
    emit(state.copyWith(status: AdminStatus.loading, clearError: true));

    try {
      final cities = await _adminApi.getCities(query: query);

      emit(
        state.copyWith(
          status: AdminStatus.success,
          cities: cities,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<bool> createCity({required String cityName}) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.createCity(cityName: cityName);
      await loadCities();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<bool> updateCity({
    required int cityId,
    required String cityName,
  }) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.updateCity(cityId: cityId, cityName: cityName);
      await loadCities();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<bool> deleteCity(int cityId) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.deleteCity(cityId);
      await loadCities();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<void> loadPickupPoints({int? cityId}) async {
    emit(state.copyWith(status: AdminStatus.loading, clearError: true));

    try {
      final pickupPoints = await _adminApi.getPickupPoints(cityId: cityId);

      emit(
        state.copyWith(
          status: AdminStatus.success,
          pickupPoints: pickupPoints,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<bool> createPickupPoint({required int houseId}) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.createPickupPoint(houseId: houseId);
      await loadPickupPoints();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<bool> updatePickupPoint({
    required int pickupPointId,
    required int houseId,
  }) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.updatePickupPoint(
        pickupPointId: pickupPointId,
        houseId: houseId,
      );
      await loadPickupPoints();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getStreetsByCity(int cityId) async {
    try {
      return await _adminApi.getStreets(cityId: cityId);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return [];
    }
  }

  Future<bool> createStreet({
    required int cityId,
    required String streetName,
  }) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.createStreet(cityId: cityId, streetName: streetName);
      emit(state.copyWith(status: AdminStatus.success, clearError: true));
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getHousesByStreet(int streetId) async {
    try {
      return await _adminApi.getHouses(streetId: streetId);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return [];
    }
  }

  Future<bool> createHouse({
    required int streetId,
    required String houseNumber,
  }) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.createHouse(streetId: streetId, houseNumber: houseNumber);
      emit(state.copyWith(status: AdminStatus.success, clearError: true));
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<bool> deletePickupPoint(int pickupPointId) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.deletePickupPoint(pickupPointId);
      await loadPickupPoints();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<void> loadProducts({
    String? query,
    int? categoryId,
    int? subcategoryId,
    int? sellerId,
  }) async {
    emit(state.copyWith(status: AdminStatus.loading, clearError: true));

    try {
      final products = await _adminApi.getProducts(
        query: query,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        sellerId: sellerId,
      );

      emit(
        state.copyWith(
          status: AdminStatus.success,
          products: products,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<bool> createProduct({
    List<Map<String, dynamic>> parameterValues = const [],
    required int categoryId,
    required int sellerId,
    required int subcategoryId,
    required String name,
    String? description,
    required String price,
    required int quantity,
    String currency = 'BYN',
  }) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.createProduct(
        categoryId: categoryId,
        sellerId: sellerId,
        parameterValues: parameterValues,
        subcategoryId: subcategoryId,
        name: name,
        description: description,
        price: price,
        quantity: quantity,
        currency: currency,
      );
      await loadProducts();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<bool> updateProduct({
    List<Map<String, dynamic>>? parameterValues,
    required int productId,
    int? categoryId,
    int? sellerId,
    int? subcategoryId,
    String? name,
    String? description,
    String? price,
    int? quantity,
    String? currency,
  }) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.updateProduct(
        productId: productId,
        categoryId: categoryId,
        sellerId: sellerId,
        subcategoryId: subcategoryId,
        parameterValues: parameterValues,
        name: name,
        description: description,
        price: price,
        quantity: quantity,
        currency: currency,
      );
      await loadProducts();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<bool> deleteProduct(int productId) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.deleteProduct(productId);
      await loadProducts();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<void> loadUsers({String? query, String? role, bool? isBlocked}) async {
    emit(state.copyWith(status: AdminStatus.loading, clearError: true));

    try {
      final users = await _adminApi.getUsers(
        query: query,
        role: role,
        isBlocked: isBlocked,
      );

      emit(
        state.copyWith(
          status: AdminStatus.success,
          users: users,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<bool> toggleUserBlocked({
    required int userId,
    required bool isBlocked,
  }) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.updateUser(userId: userId, isBlocked: isBlocked);
      await loadUsers();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<bool> deleteUser(int userId) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.deleteUser(userId);
      await loadUsers();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<void> loadReviews({String? status}) async {
    emit(state.copyWith(status: AdminStatus.loading, clearError: true));

    try {
      final reviews = await _adminApi.getReviews(status: status);

      emit(
        state.copyWith(
          status: AdminStatus.success,
          reviews: reviews,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<bool> updateReviewModerationStatus({
    required int reviewId,
    required String moderationStatus,
    String? currentFilter,
  }) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.updateReviewModerationStatus(
        reviewId: reviewId,
        moderationStatus: moderationStatus,
      );
      await loadReviews(status: currentFilter);
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<void> loadSellers({String? query}) async {
    emit(state.copyWith(status: AdminStatus.loading, clearError: true));

    try {
      final sellers = await _adminApi.getSellers(query: query);

      emit(
        state.copyWith(
          status: AdminStatus.success,
          sellers: sellers,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<bool> createSeller({
    required String shopName,
    String? description,
    String? inn,
    String? unp,
    required int userId,
  }) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.createSeller(
        shopName: shopName,
        description: description,
        inn: inn,
        unp: unp,
        userId: userId,
      );
      await loadSellers();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<bool> updateSeller({
    required int sellerId,
    String? shopName,
    String? description,
    String? inn,
    String? unp,
    int? userId,
  }) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.updateSeller(
        sellerId: sellerId,
        shopName: shopName,
        description: description,
        inn: inn,
        unp: unp,
        userId: userId,
      );
      await loadSellers();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<bool> deleteSeller(int sellerId) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.deleteSeller(sellerId);
      await loadSellers();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<bool> createCategory({required String categoryName}) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.createCategory(categoryName: categoryName);
      await loadAll();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<bool> updateCategory({
    required int categoryId,
    required String categoryName,
  }) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.updateCategory(
        categoryId: categoryId,
        categoryName: categoryName,
      );
      await loadAll();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<bool> deleteCategory(int categoryId) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.deleteCategory(categoryId);
      await loadAll();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<void> loadAdminSubcategories({String? query, int? categoryId}) async {
    emit(state.copyWith(status: AdminStatus.loading, clearError: true));

    try {
      final items = await _adminApi.getSubcategories(
        query: query,
        categoryId: categoryId,
      );

      emit(
        state.copyWith(
          status: AdminStatus.success,
          categories: state.categories,
          adminSubcategories: items,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<bool> createSubcategory({
    required String name,
    required int categoryId,
  }) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.createSubcategory(name: name, categoryId: categoryId);
      await loadAdminSubcategories();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<bool> updateSubcategory({
    required int subcategoryId,
    String? name,
    int? categoryId,
  }) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.updateSubcategory(
        subcategoryId: subcategoryId,
        name: name,
        categoryId: categoryId,
      );
      await loadAdminSubcategories();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<bool> deleteSubcategory(int subcategoryId) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.deleteSubcategory(subcategoryId);
      await loadAdminSubcategories();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: AdminStatus.loading, clearError: true));

    try {
      final stats = await _adminApi.getStats();
      final orders = await _adminApi.getOrders(status: 'created');

      emit(
        state.copyWith(
          status: AdminStatus.success,
          stats: stats,
          orders: orders,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> loadCategoriesOnly() async {
    emit(state.copyWith(status: AdminStatus.loading, clearError: true));

    try {
      final categories = await _adminApi.getCategories();

      emit(
        state.copyWith(
          status: AdminStatus.success,
          categories: categories,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<bool> createMeasurementUnit({
    required String name,
    required String shortName,
  }) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.createMeasurementUnit(name: name, shortName: shortName);
      await loadAll();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }

  Future<bool> deleteMeasurementUnit(int unitId) async {
    emit(state.copyWith(status: AdminStatus.saving, clearError: true));

    try {
      await _adminApi.deleteMeasurementUnit(unitId);
      await loadAll();
      return true;
    } catch (e) {
      emit(
        state.copyWith(status: AdminStatus.error, errorMessage: e.toString()),
      );
      return false;
    }
  }
}
