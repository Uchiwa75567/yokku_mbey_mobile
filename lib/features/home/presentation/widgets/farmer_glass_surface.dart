import 'package:flutter/material.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

// Compatibility wrappers for the older farmer views, now using solid surfaces.
class FarmerGlassBackground extends StatelessWidget {
  const FarmerGlassBackground(
      {super.key,
      this.assetPath = AppAssets.farmerHomeBackground,
      this.overlayOpacity = 0.40,
      this.blurSigma = 1.5});
  final String assetPath;
  final double overlayOpacity, blurSigma;
  @override
  Widget build(BuildContext context) => const ColoredBox(color: Colors.white);
}

class FarmerGlassSurface extends StatelessWidget {
  const FarmerGlassSurface(
      {super.key,
      required this.child,
      required this.color,
      this.borderRadius = BorderRadius.zero,
      this.blurSigma = 16,
      this.borderColor = const Color(0x33FFFFFF),
      this.boxShadow = const []});
  final Widget child;
  final Color color, borderColor;
  final BorderRadius borderRadius;
  final double blurSigma;
  final List<BoxShadow> boxShadow;
  @override
  Widget build(BuildContext context) => DecoratedBox(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border)),
      child: child);
}
