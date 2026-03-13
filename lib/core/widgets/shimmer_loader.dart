import 'package:flutter/material.dart';
import 'package:diplomeprojectmobile/app/theme/colors.dart';

class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({super.key, this.height = 120, this.radius = 20});

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
