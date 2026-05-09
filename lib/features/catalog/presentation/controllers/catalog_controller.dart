import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/features/catalog/data/datasources/catalog_api.dart';
import 'package:diplomeprojectmobile/features/catalog/data/repos/catalog_repo_impl.dart';
import 'package:diplomeprojectmobile/features/catalog/domain/usecases/get_categories_usecase.dart';
import 'package:diplomeprojectmobile/features/catalog/domain/usecases/get_products_by_category_usecase.dart';
import 'package:diplomeprojectmobile/features/catalog/domain/usecases/search_products_usecase.dart';
import 'package:diplomeprojectmobile/core/utils/error_mapper.dart';
import 'catalog_state.dart';

class CatalogController extends Cubit<CatalogState> {
  CatalogController({required CatalogApi catalogApi})
    : _catalogApi = catalogApi,
      _getCategoriesUseCase = GetCategoriesUseCase(_buildRepo(catalogApi)),
      _getProductsByCategoryUseCase = GetProductsByCategoryUseCase(
        _buildRepo(catalogApi),
      ),
      _searchProductsUseCase = SearchProductsUseCase(_buildRepo(catalogApi)),
      super(const CatalogState());

  final CatalogApi _catalogApi;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetProductsByCategoryUseCase _getProductsByCategoryUseCase;
  final SearchProductsUseCase _searchProductsUseCase;

  static CatalogRepoImpl _buildRepo(CatalogApi catalogApi) {
    return CatalogRepoImpl(catalogApi);
  }

  Future<void> loadHome() async {
    emit(state.copyWith(status: CatalogStatus.loading, clearError: true));

    try {
      final categories = await _getCategoriesUseCase();
      final products = await _getProductsByCategoryUseCase();

      emit(
        state.copyWith(
          status: CatalogStatus.success,
          categories: categories,
          products: products,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CatalogStatus.error,
          errorMessage: ErrorMapper.map(e),
        ),
      );
    }
  }

  Future<void> loadSubcategories(int categoryId) async {
    try {
      final subcategories = await _catalogApi.getSubcategories(categoryId);

      emit(
        state.copyWith(
          subcategories: subcategories,
          selectedCategoryId: categoryId,
          clearSelectedSubcategory: true,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CatalogStatus.error,
          errorMessage: ErrorMapper.map(e),
        ),
      );
    }
  }

  Future<void> _loadAvailableParameters({required int? subcategoryId}) async {
    if (subcategoryId == null) {
      emit(state.copyWith(availableParameters: const []));
      return;
    }

    try {
      final parameters = await _catalogApi.getSubcategoryFilters(subcategoryId);

      final onlyWithValues = parameters.where((item) {
        final values = item['values'] as List<dynamic>? ?? const [];
        return values.isNotEmpty;
      }).toList();

      emit(state.copyWith(availableParameters: onlyWithValues));
    } catch (_) {
      emit(state.copyWith(availableParameters: const []));
    }
  }

  Future<void> _loadProducts({
    int? categoryId,
    int? subcategoryId,
    String? searchQuery,
    String? minPrice,
    String? maxPrice,
    double? minRating,
    String? sortBy,
    Map<int, String>? parameterFilters,
  }) async {
    final products = await _catalogApi.getProducts(
      categoryId: categoryId ?? state.selectedCategoryId,
      subcategoryId: subcategoryId ?? state.selectedSubcategoryId,
      searchQuery: searchQuery ?? state.searchQuery,
      minPrice: minPrice ?? state.minPrice,
      maxPrice: maxPrice ?? state.maxPrice,
      minRating: minRating ?? state.minRating,
      sortBy: sortBy ?? state.sortBy,
      parameterFilters: parameterFilters ?? state.parameterFilters,
    );

    emit(
      state.copyWith(
        status: CatalogStatus.success,
        products: products,
        selectedCategoryId: categoryId ?? state.selectedCategoryId,
        selectedSubcategoryId: subcategoryId ?? state.selectedSubcategoryId,
        searchQuery: searchQuery ?? state.searchQuery,
        minPrice: minPrice ?? state.minPrice,
        maxPrice: maxPrice ?? state.maxPrice,
        minRating: minRating ?? state.minRating,
        sortBy: sortBy ?? state.sortBy,
        parameterFilters: parameterFilters ?? state.parameterFilters,
        clearError: true,
      ),
    );
  }

  Future<void> selectCategory(int? categoryId, {int? subcategoryId}) async {
    emit(
      state.copyWith(
        status: CatalogStatus.loading,
        selectedCategoryId: categoryId,
        selectedSubcategoryId: subcategoryId,
        clearError: true,
      ),
    );

    try {
      await _loadProducts(categoryId: categoryId, subcategoryId: subcategoryId);

      await _loadAvailableParameters(subcategoryId: subcategoryId);
    } catch (e) {
      emit(
        state.copyWith(
          status: CatalogStatus.error,
          errorMessage: ErrorMapper.map(e),
        ),
      );
    }
  }

  Future<void> search(String query) async {
    final q = query.trim();

    emit(
      state.copyWith(
        status: CatalogStatus.loading,
        searchQuery: q,
        clearError: true,
      ),
    );

    try {
      await _loadProducts(searchQuery: q);

      // Если есть найденные товары - определяем их подкатегорию
      if (state.products.isNotEmpty) {
        // Берем subcategory_id первого товара
        final firstProduct = state.products.first;
        
        if (firstProduct.subcategoryId != null) {
          // Загружаем фильтры для найденной подкатегории
          await _loadAvailableParameters(subcategoryId: firstProduct.subcategoryId);
          
          // Сохраняем выбранную подкатегорию
          emit(state.copyWith(selectedSubcategoryId: firstProduct.subcategoryId));
        } else {
          emit(state.copyWith(availableParameters: const []));
        }
        return;
      }

      // Если товары не найдены - очищаем фильтры
      if (q.isEmpty) {
        emit(state.copyWith(availableParameters: const []));
        return;
      }

      // Fallback: пробуем получить фильтры через API
      final result = await _catalogApi.getSearchFilters(q);
      final detectedSubcategoryId = int.tryParse(
        result['subcategory_id']?.toString() ?? '',
      );

      final items = (result['items'] as List<dynamic>? ?? const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      emit(
        state.copyWith(
          availableParameters: items,
          selectedSubcategoryId:
              detectedSubcategoryId != null && detectedSubcategoryId > 0
              ? detectedSubcategoryId
              : state.selectedSubcategoryId,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CatalogStatus.error,
          errorMessage: ErrorMapper.map(e),
        ),
      );
    }
  }

  Future<void> applyFilters({
    String? minPrice,
    String? maxPrice,
    double? minRating,
    Map<int, String>? parameterFilters,
  }) async {
    emit(
      state.copyWith(
        status: CatalogStatus.loading,
        minPrice: minPrice ?? state.minPrice,
        maxPrice: maxPrice ?? state.maxPrice,
        minRating: minRating ?? state.minRating,
        parameterFilters: parameterFilters ?? state.parameterFilters,
        clearError: true,
      ),
    );

    try {
      await _loadProducts(
        minPrice: minPrice ?? state.minPrice,
        maxPrice: maxPrice ?? state.maxPrice,
        minRating: minRating ?? state.minRating,
        parameterFilters: parameterFilters ?? state.parameterFilters,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CatalogStatus.error,
          errorMessage: ErrorMapper.map(e),
        ),
      );
    }
  }

  Future<void> applySort(String sortBy) async {
    emit(
      state.copyWith(
        status: CatalogStatus.loading,
        sortBy: sortBy,
        clearError: true,
      ),
    );

    try {
      await _loadProducts(sortBy: sortBy);
    } catch (e) {
      emit(
        state.copyWith(
          status: CatalogStatus.error,
          errorMessage: ErrorMapper.map(e),
        ),
      );
    }
  }

  Future<void> clearFilters() async {
    emit(
      state.copyWith(
        status: CatalogStatus.loading,
        clearPrices: true,
        clearRating: true,
        clearParameterFilters: true,
        clearError: true,
      ),
    );

    try {
      await _loadProducts(
        minPrice: '',
        maxPrice: '',
        minRating: null,
        parameterFilters: {},
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CatalogStatus.error,
          errorMessage: ErrorMapper.map(e),
        ),
      );
    }
  }
}
