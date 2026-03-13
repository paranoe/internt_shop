import 'package:diplomeprojectmobile/features/catalog/data/datasources/catalog_api.dart';
import 'package:diplomeprojectmobile/features/catalog/domain/entities/category.dart';
import 'package:diplomeprojectmobile/features/catalog/domain/entities/product_card.dart';
import 'package:diplomeprojectmobile/features/catalog/domain/repos/catalog_repo.dart';

class CatalogRepoImpl implements CatalogRepo {
  const CatalogRepoImpl(this._api);

  final CatalogApi _api;

  @override
  Future<List<Category>> getCategories() {
    return _api.getCategories();
  }

  @override
  Future<List<ProductCardEntity>> getProductsByCategory({int? categoryId}) {
    return _api.getProductsByCategory(categoryId: categoryId);
  }

  @override
  Future<List<ProductCardEntity>> searchProducts({required String query}) {
    return _api.searchProducts(query: query);
  }
}
