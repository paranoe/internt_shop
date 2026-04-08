import 'package:flutter/material.dart';
import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/features/reviews/domain/entities/review.dart';

class ReviewTile extends StatelessWidget {
  const ReviewTile({super.key, required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (review.buyerName?.trim().isNotEmpty ?? false)
                ? review.buyerName!
                : 'Покупатель',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < review.rating
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                size: 18,
                color: Colors.amber,
              ),
            ),
          ),
          if ((review.comment?.trim().isNotEmpty ?? false)) ...[
            const SizedBox(height: 10),
            Text(review.comment!),
          ],
          if ((review.createdAt?.trim().isNotEmpty ?? false)) ...[
            const SizedBox(height: 10),
            Text(
              review.createdAt!,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
