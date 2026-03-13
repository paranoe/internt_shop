import 'package:diplomeprojectmobile/features/product/domain/entities/product_image.dart';
import 'package:diplomeprojectmobile/features/product/domain/repos/product_repo.dart';

class GetProductImagesUseCase {
  const GetProductImagesUseCase(this._repo);

  final ProductRepo _repo;

  Future<List<ProductImage>> call(int productId) =>
      _repo.getProductImages(productId);
}
