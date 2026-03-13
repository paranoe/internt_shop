import 'package:diplomeprojectmobile/features/catalog/domain/entities/product_card.dart';
import 'package:diplomeprojectmobile/features/catalog/domain/repos/catalog_repo.dart';

class GetProductsByCategoryUseCase {
  const GetProductsByCategoryUseCase(this._repo);

  final CatalogRepo _repo;

  Future<List<ProductCardEntity>> call({int? categoryId}) {
    return _repo.getProductsByCategory(categoryId: categoryId);
  }
}
