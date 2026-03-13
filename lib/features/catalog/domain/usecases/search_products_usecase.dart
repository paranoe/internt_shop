import 'package:diplomeprojectmobile/features/catalog/domain/entities/product_card.dart';
import 'package:diplomeprojectmobile/features/catalog/domain/repos/catalog_repo.dart';

class SearchProductsUseCase {
  const SearchProductsUseCase(this._repo);

  final CatalogRepo _repo;

  Future<List<ProductCardEntity>> call({required String query}) {
    return _repo.searchProducts(query: query);
  }
}
