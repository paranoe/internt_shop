import 'package:diplomeprojectmobile/features/product/data/datasources/product_api.dart';
import 'package:diplomeprojectmobile/features/product/domain/entities/product_details.dart';
import 'package:diplomeprojectmobile/features/product/domain/entities/product_image.dart';
import 'package:diplomeprojectmobile/features/product/domain/entities/product_parameter.dart';
import 'package:diplomeprojectmobile/features/product/domain/entities/review.dart';
import 'package:diplomeprojectmobile/features/product/domain/repos/product_repo.dart';

class ProductRepoImpl implements ProductRepo {
  const ProductRepoImpl(this._api);

  final ProductApi _api;

  @override
  Future<ProductDetails> getProductDetails(int productId) {
    return _api.getProductDetails(productId);
  }

  @override
  Future<List<ProductImage>> getProductImages(int productId) {
    return _api.getProductImages(productId);
  }

  @override
  Future<List<ProductParameter>> getProductParameters(int productId) {
    return _api.getProductParameters(productId);
  }

  @override
  Future<List<ProductReview>> getProductReviews(int productId) {
    return _api.getProductReviews(productId);
  }
}
