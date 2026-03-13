import 'package:flutter/material.dart';
import 'package:diplomeprojectmobile/features/cart/domain/entities/cart_item.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.onToggleSelected,
    required this.onDecrease,
    required this.onIncrease,
    required this.onDelete,
  });

  final CartItem item;
  final VoidCallback onToggleSelected;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onDelete;

  String _lineTotal() {
    final price = double.tryParse(item.price) ?? 0;
    return '${(price * item.quantity).toStringAsFixed(2)} ${item.currency}';
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = item.mainImage != null && item.mainImage!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 28),
            child: Checkbox(
              value: item.selectedForPurchase,
              onChanged: (_) => onToggleSelected(),
              activeColor: const Color(0xFF2563EB),
              side: const BorderSide(color: Colors.white54),
            ),
          ),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(18),
            ),
            child: hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      item.mainImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.white38,
                      size: 34,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 110,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _lineTotal(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF472B6),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      item.productName,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _SquareButton(
                        icon: Icons.delete_outline,
                        onTap: onDelete,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: onDecrease,
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              onPressed: onIncrease,
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white70),
      ),
    );
  }
}
