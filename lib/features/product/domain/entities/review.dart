class ProductReview {
  const ProductReview({
    required this.reviewId,
    required this.buyerId,
    required this.rating,
    this.comment,
    this.buyerName,
    this.createdAt,
  });

  final int reviewId;
  final int buyerId;
  final int rating;
  final String? comment;
  final String? buyerName;
  final DateTime? createdAt;
}
