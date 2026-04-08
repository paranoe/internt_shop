import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:diplomeprojectmobile/features/reviews/presentation/controllers/reviews_controller.dart';
import 'package:diplomeprojectmobile/features/reviews/presentation/controllers/reviews_state.dart';
import 'package:diplomeprojectmobile/features/reviews/presentation/widgets/review_tile.dart';

class ProductReviewsScreen extends StatefulWidget {
  const ProductReviewsScreen({super.key, required this.productId});

  final int productId;

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewsController>().loadProductReviews(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Отзывы'), centerTitle: true),
      body: BlocBuilder<ReviewsController, ReviewsState>(
        builder: (context, state) {
          if (state.status == ReviewsStatus.loading && state.reviews.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ReviewsStatus.error && state.reviews.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.errorMessage ?? 'Не удалось загрузить отзывы',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        context.read<ReviewsController>().loadProductReviews(
                          widget.productId,
                        );
                      },
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.reviews.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context
                  .read<ReviewsController>()
                  .loadProductReviews(widget.productId),
              child: ListView(
                children: const [
                  SizedBox(height: 140),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.rate_review_outlined, size: 64),
                        SizedBox(height: 12),
                        Text(
                          'Отзывов пока нет',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context
                .read<ReviewsController>()
                .loadProductReviews(widget.productId),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.reviews.length,
              itemBuilder: (context, index) {
                return ReviewTile(review: state.reviews[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
