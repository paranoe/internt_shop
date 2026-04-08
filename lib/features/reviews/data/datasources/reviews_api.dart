import 'package:diplomeprojectmobile/core/network/api_endpoints.dart';
import 'package:diplomeprojectmobile/core/network/dio_client.dart';
import '../models/review_model.dart';
import 'package:dio/dio.dart';

class ReviewsApi {
  const ReviewsApi(this._dioClient);

  final DioClient _dioClient;

  List<dynamic> _extractItems(dynamic data) {
    if (data is List) return data;

    final map = Map<String, dynamic>.from(data as Map);
    return map['items'] as List<dynamic>? ?? [];
  }

  Future<List<ReviewModel>> getProductReviews(int productId) async {
    final response = await _dioClient.dio.get(
      '${ApiEndpoints.products}/$productId/reviews',
    );

    final items = _extractItems(response.data);

    return items
        .map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> addReview({
    required int productId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _dioClient.dio.post(
        '/reviews',
        data: {
          'product_id': productId,
          'rating': rating,
          'comment': comment?.trim().isEmpty == true ? null : comment?.trim(),
        },
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;

      if (status == 403 && data is Map && data['error'] != null) {
        final message = data['error'].toString();

        if (message.contains(
          'You can review only delivered purchased products',
        )) {
          throw Exception(
            'Оставить отзыв можно только на купленный и уже доставленный товар.',
          );
        }

        throw Exception(message);
      }

      if (status == 400 && data is Map && data['error'] != null) {
        throw Exception(data['error'].toString());
      }

      throw Exception('Не удалось отправить отзыв');
    }
  }
}
