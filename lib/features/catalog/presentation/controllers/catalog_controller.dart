import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/features/catalog/data/datasources/catalog_api.dart';
import 'package:diplomeprojectmobile/features/catalog/data/repos/catalog_repo_impl.dart';
import 'package:diplomeprojectmobile/features/catalog/domain/usecases/get_categories_usecase.dart';
import 'package:diplomeprojectmobile/features/catalog/domain/usecases/get_products_by_category_usecase.dart';
import 'package:diplomeprojectmobile/features/catalog/domain/usecases/search_products_usecase.dart';
import 'catalog_state.dart';

class CatalogController extends Cubit<CatalogState> {
  CatalogController({required CatalogApi catalogApi})
    : _getCategoriesUseCase = GetCategoriesUseCase(CatalogRepoImpl(catalogApi)),
      _getProductsByCategoryUseCase = GetProductsByCategoryUseCase(
        CatalogRepoImpl(catalogApi),
      ),
      _searchProductsUseCase = SearchProductsUseCase(
        CatalogRepoImpl(catalogApi),
      ),
      super(const CatalogState());

  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetProductsByCategoryUseCase _getProductsByCategoryUseCase;
  final SearchProductsUseCase _searchProductsUseCase;

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
        state.copyWith(status: CatalogStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> selectCategory(int? categoryId) async {
    emit(
      state.copyWith(
        status: CatalogStatus.loading,
        selectedCategoryId: categoryId,
        clearError: true,
      ),
    );

    try {
      final products = await _getProductsByCategoryUseCase(
        categoryId: categoryId,
      );

      emit(
        state.copyWith(
          status: CatalogStatus.success,
          products: products,
          selectedCategoryId: categoryId,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CatalogStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> search(String query) async {
    final q = query.trim();

    if (q.isEmpty) {
      await selectCategory(state.selectedCategoryId);
      return;
    }

    emit(state.copyWith(status: CatalogStatus.loading, clearError: true));

    try {
      final products = await _searchProductsUseCase(query: q);

      emit(
        state.copyWith(
          status: CatalogStatus.success,
          products: products,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CatalogStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
