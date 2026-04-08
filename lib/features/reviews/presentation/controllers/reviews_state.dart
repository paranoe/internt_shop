import 'package:equatable/equatable.dart';
import 'package:diplomeprojectmobile/features/reviews/domain/entities/review.dart';

enum ReviewsStatus { initial, loading, success, submitting, error }

class ReviewsState extends Equatable {
  const ReviewsState({
    this.status = ReviewsStatus.initial,
    this.reviews = const [],
    this.errorMessage,
    this.lastAddedSuccessfully = false,
  });

  final ReviewsStatus status;
  final List<Review> reviews;
  final String? errorMessage;
  final bool lastAddedSuccessfully;

  ReviewsState copyWith({
    ReviewsStatus? status,
    List<Review>? reviews,
    String? errorMessage,
    bool clearError = false,
    bool? lastAddedSuccessfully,
  }) {
    return ReviewsState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastAddedSuccessfully:
          lastAddedSuccessfully ?? this.lastAddedSuccessfully,
    );
  }

  @override
  List<Object?> get props => [
    status,
    reviews,
    errorMessage,
    lastAddedSuccessfully,
  ];
}
