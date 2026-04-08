import 'package:diplomeprojectmobile/features/reviews/domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.reviewId,
    required super.productId,
    required super.rating,
    super.comment,
    super.buyerName,
    super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) => int.tryParse(value.toString()) ?? 0;

    return ReviewModel(
      reviewId: toInt(json['review_id']),
      productId: toInt(json['product_id']),
      rating: toInt(json['rating']),
      comment: json['comment']?.toString(),
      buyerName: json['buyer_name']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}