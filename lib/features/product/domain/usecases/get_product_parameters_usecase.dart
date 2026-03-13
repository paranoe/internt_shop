import 'package:diplomeprojectmobile/features/product/domain/entities/product_parameter.dart';
import 'package:diplomeprojectmobile/features/product/domain/repos/product_repo.dart';

class GetProductParametersUseCase {
  const GetProductParametersUseCase(this._repo);

  final ProductRepo _repo;

  Future<List<ProductParameter>> call(int productId) =>
      _repo.getProductParameters(productId);
}
