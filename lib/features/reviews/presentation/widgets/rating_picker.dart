import 'package:flutter/material.dart';

class RatingPicker extends StatelessWidget {
  const RatingPicker({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final star = index + 1;
        final selected = star <= value;

        return IconButton(
          onPressed: () => onChanged(star),
          icon: Icon(
            selected ? Icons.star_rounded : Icons.star_border_rounded,
            color: selected ? Colors.amber : Colors.grey,
            size: 30,
          ),
        );
      }),
    );
  }
}
