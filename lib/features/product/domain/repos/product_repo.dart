import 'package:diplomeprojectmobile/features/product/domain/entities/product_details.dart';
import 'package:diplomeprojectmobile/features/product/domain/entities/product_image.dart';
import 'package:diplomeprojectmobile/features/product/domain/entities/product_parameter.dart';
import 'package:diplomeprojectmobile/features/product/domain/entities/review.dart';

abstract class ProductRepo {
  Future<ProductDetails> getProductDetails(int productId);
  Future<List<ProductImage>> getProductImages(int productId);
  Future<List<ProductParameter>> getProductParameters(int productId);
  Future<List<ProductReview>> getProductReviews(int productId);
}
