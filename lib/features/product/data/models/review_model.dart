import 'package:diplomeprojectmobile/features/product/domain/entities/review.dart';

class ReviewModel extends ProductReview {
  const ReviewModel({
    required super.reviewId,
    required super.buyerId,
    required super.rating,
    super.comment,
    super.buyerName,
    super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviewId: int.parse(json['review_id'].toString()),
      buyerId: int.parse(json['buyer_id'].toString()),
      rating: int.parse(json['rating'].toString()),
      comment: json['comment']?.toString(),
      buyerName: json['buyer_name']?.toString(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }
}
