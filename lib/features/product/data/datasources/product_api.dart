import 'package:diplomeprojectmobile/core/network/api_endpoints.dart';
import 'package:diplomeprojectmobile/core/network/dio_client.dart';

import '../models/product_details_model.dart';
import '../models/product_image_model.dart';
import '../models/product_parameter_model.dart';
import '../models/review_model.dart';

class ProductApi {
  const ProductApi(this._dioClient);

  final DioClient _dioClient;

  Future<ProductDetailsModel> getProductDetails(int productId) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.products}/$productId',
    );
    return ProductDetailsModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<List<ProductImageModel>> getProductImages(int productId) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.products}/$productId/images',
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    final items = (data['items'] as List<dynamic>? ?? []);
    return items
        .map(
          (e) =>
              ProductImageModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  Future<List<ProductParameterModel>> getProductParameters(
    int productId,
  ) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.products}/$productId/parameters',
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    final items = (data['items'] as List<dynamic>? ?? []);
    return items
        .map(
          (e) => ProductParameterModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  Future<List<ReviewModel>> getProductReviews(int productId) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.products}/$productId/reviews',
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    final items = (data['items'] as List<dynamic>? ?? []);
    return items
        .map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
