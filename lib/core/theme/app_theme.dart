import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.leaf).copyWith(
        primary: AppColors.leaf,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: AppColors.ink,
        surfaceContainerHighest: AppColors.canvas,
        outline: AppColors.border,
      ),
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.2,
            color: AppColors.ink,
            letterSpacing: 0),
        titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: 0),
        titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
            letterSpacing: 0),
        bodyLarge: TextStyle(
            fontSize: 16, height: 1.45, color: AppColors.ink, letterSpacing: 0),
        bodyMedium: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: AppColors.mutedInk,
            letterSpacing: 0),
        labelLarge: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0),
      ),
      appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.ink,
          surfaceTintColor: Colors.transparent,
          elevation: 0),
      dividerTheme: const DividerThemeData(
          color: AppColors.border, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.optionBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.softInk, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.mutedInk),
        floatingLabelStyle: const TextStyle(color: AppColors.leaf),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.leaf, width: 1.5)),
      ),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      )),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      )),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: AppColors.leafLight,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        labelStyle: const TextStyle(
            fontFamily: 'Roboto', fontSize: 13, color: AppColors.mutedInk),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          showDragHandle: true),
      snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating, backgroundColor: AppColors.ink),
    );
  }
}
