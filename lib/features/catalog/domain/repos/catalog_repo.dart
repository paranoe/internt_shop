import 'package:diplomeprojectmobile/features/catalog/domain/entities/category.dart';
import 'package:diplomeprojectmobile/features/catalog/domain/entities/product_card.dart';

abstract class CatalogRepo {
  Future<List<Category>> getCategories();

  Future<List<ProductCardEntity>> getProductsByCategory({int? categoryId});

  Future<List<ProductCardEntity>> searchProducts({required String query});
}
