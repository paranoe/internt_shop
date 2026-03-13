import 'package:flutter/material.dart';
import 'colors.dart';

class AppTypography {
  AppTypography._();

  static const fontFamily = 'SF Pro Text';

  static TextTheme get textTheme {
    return const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.4,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}
