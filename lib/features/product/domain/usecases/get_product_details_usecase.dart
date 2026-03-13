import 'package:diplomeprojectmobile/features/product/domain/entities/product_details.dart';
import 'package:diplomeprojectmobile/features/product/domain/repos/product_repo.dart';

class GetProductDetailsUseCase {
  const GetProductDetailsUseCase(this._repo);

  final ProductRepo _repo;

  Future<ProductDetails> call(int productId) =>
      _repo.getProductDetails(productId);
}
