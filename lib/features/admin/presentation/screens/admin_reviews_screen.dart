import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:diplomeprojectmobile/app/theme/colors.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_controller.dart';
import 'package:diplomeprojectmobile/features/admin/presentation/controllers/admin_state.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadReviews();
    });
  }

  Color _statusColor(String status) {
    final value = status.trim().toLowerCase();

    if (value == 'pending') return Colors.orange;
    if (value == 'approved') return Colors.green;
    if (value == 'rejected') return Colors.red;

    return Colors.grey;
  }

  String _statusRu(String status) {
    final value = status.trim().toLowerCase();

    if (value == 'pending') return 'На модерации';
    if (value == 'approved') return 'Одобрен';
    if (value == 'rejected') return 'Отклонён';

    return status;
  }

  Future<void> _changeStatus({
    required int reviewId,
    required String moderationStatus,
  }) async {
    final ok = await context
        .read<AdminController>()
        .updateReviewModerationStatus(
          reviewId: reviewId,
          moderationStatus: moderationStatus,
          currentFilter: _selectedStatus,
        );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Статус отзыва обновлён' : 'Не удалось обновить статус отзыва',
        ),
      ),
    );
  }

  Future<void> _openReviewDetails(Map<String, dynamic> review) async {
    final reviewId = int.tryParse(review['review_id'].toString()) ?? 0;
    final status = review['moderation_status']?.toString() ?? 'pending';
    final productName = review['product_name']?.toString() ?? 'Товар';
    final buyerName = review['buyer_name']?.toString() ?? 'Пользователь';
    final buyerEmail = review['buyer_email']?.toString() ?? '—';
    final rating = review['rating']?.toString() ?? '—';
    final comment = review['comment']?.toString() ?? 'Без комментария';
    final createdAt = review['created_at']?.toString() ?? '—';
    final color = _statusColor(status);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: BoxDecoration(
            color: Theme.of(sheetContext).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Отзыв #$reviewId',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusRu(status),
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Товар: $productName'),
                Text('Пользователь: $buyerName'),
                Text('Email: $buyerEmail'),
                Text('Оценка: $rating'),
                Text('Дата: $createdAt'),
                const SizedBox(height: 16),
                const Text(
                  'Комментарий',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(comment),
                ),
                const SizedBox(height: 20),
                if (status != 'approved')
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        Navigator.of(sheetContext).pop();
                        await _changeStatus(
                          reviewId: reviewId,
                          moderationStatus: 'approved',
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Одобрить'),
                    ),
                  ),
                if (status != 'approved') const SizedBox(height: 10),
                if (status != 'rejected')
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.of(sheetContext).pop();
                        await _changeStatus(
                          reviewId: reviewId,
                          moderationStatus: 'rejected',
                        );
                      },
                      icon: const Icon(Icons.block_outlined),
                      label: const Text('Отклонить'),
                    ),
                  ),
                if (status != 'pending') const SizedBox(height: 10),
                if (status != 'pending')
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () async {
                        Navigator.of(sheetContext).pop();
                        await _changeStatus(
                          reviewId: reviewId,
                          moderationStatus: 'pending',
                        );
                      },
                      icon: const Icon(Icons.hourglass_empty),
                      label: const Text('Вернуть на модерацию'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Модерация отзывов'), centerTitle: true),
      body: BlocBuilder<AdminController, AdminState>(
        builder: (context, state) {
          if (state.status == AdminStatus.loading && state.reviews.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AdminStatus.error && state.reviews.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? 'Не удалось загрузить отзывы',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<AdminController>().loadReviews(
              status: _selectedStatus,
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<String?>(
                  initialValue: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Фильтр по статусу',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Все статусы'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'pending',
                      child: Text('На модерации'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'approved',
                      child: Text('Одобрен'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'rejected',
                      child: Text('Отклонён'),
                    ),
                  ],
                  onChanged: (value) async {
                    setState(() {
                      _selectedStatus = value;
                    });
                    await context.read<AdminController>().loadReviews(
                      status: value,
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (state.reviews.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text('Отзывов пока нет'),
                  )
                else
                  ...state.reviews.map((review) {
                    final reviewId =
                        int.tryParse(review['review_id'].toString()) ?? 0;
                    final productName =
                        review['product_name']?.toString() ?? 'Товар';
                    final buyerName =
                        review['buyer_name']?.toString() ?? 'Пользователь';
                    final rating = review['rating']?.toString() ?? '—';
                    final comment = review['comment']?.toString() ?? '';
                    final createdAt = review['created_at']?.toString() ?? '—';
                    final status =
                        review['moderation_status']?.toString() ?? 'pending';
                    final statusColor = _statusColor(status);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Отзыв #$reviewId',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            productName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _statusRu(status),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Автор: $buyerName'),
                          Text('Оценка: $rating'),
                          Text('Дата: $createdAt'),
                          if (comment.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              comment,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey.shade800),
                            ),
                          ],
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _openReviewDetails(review),
                                  icon: const Icon(Icons.visibility_outlined),
                                  label: const Text('Подробнее'),
                                ),
                              ),
                              if (status != 'approved') ...[
                                const SizedBox(width: 10),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () => _changeStatus(
                                      reviewId: reviewId,
                                      moderationStatus: 'approved',
                                    ),
                                    child: const Text('Одобрить'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
