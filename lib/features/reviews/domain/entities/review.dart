class Review {
  const Review({
    required this.reviewId,
    required this.productId,
    required this.rating,
    this.comment,
    this.buyerName,
    this.createdAt,
  });

  final int reviewId;
  final int productId;
  final int rating;
  final String? comment;
  final String? buyerName;
  final String? createdAt;
}
