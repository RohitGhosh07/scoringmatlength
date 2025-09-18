import 'package:flutter/material.dart';

class AppColors {
  // Primary green variants
  static const primary = Color(0xFF148D61);
  static const primaryLight = Color(0xFF30B082);
  static const primaryLighter = Color(0xFF67C196);
  static const primaryDark = Color(0xFF17875F);

  // Light theme
  static const lightBackground = Color(0xFFF7F8FA);
  static const lightSurface = Colors.white;
  static const lightText = Color(0xFF1A1D1F);
  static const lightTextSecondary = Color(0xFF6C7072);

  // Dark theme
  static const darkBackground = Color(0xFF0F1216);
  static const darkSurface = Color(0xFF1A1D1F);
  static const darkText = Color(0xFFF7F8FA);
  static const darkTextSecondary = Color(0xFFB4B6B8);

  // Shadows
  static const shadowColor = Color(0x1A000000);
  static const darkShadowColor = Color(0x1AFFFFFF);

  // Ring colors for target area
  static const List<Color> ringColors = [
    Color(0xFF148D61), // 0 (innermost)
    Color(0xFF30B082), // 1
    Color(0xFF67C196), // 2
    Color(0xFF94D2B2), // 3
    Color(0xFFBEE3CE), // 4 (outermost)
  ];
}
