import 'package:diplomeprojectmobile/features/catalog/domain/entities/category.dart';
import 'package:diplomeprojectmobile/features/catalog/domain/repos/catalog_repo.dart';

class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repo);

  final CatalogRepo _repo;

  Future<List<Category>> call() {
    return _repo.getCategories();
  }
}
