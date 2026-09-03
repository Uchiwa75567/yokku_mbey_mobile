import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_assets.dart';

class FarmerGlassBackground extends StatelessWidget {
  const FarmerGlassBackground({
    super.key,
    this.assetPath = AppAssets.farmerHomeBackground,
    this.overlayOpacity = 0.40,
    this.blurSigma = 1.5,
  });

  final String assetPath;
  final double overlayOpacity;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ui.ImageFilter.blur(
            sigmaX: blurSigma,
            sigmaY: blurSigma,
          ),
          child: Transform.scale(
            scale: 1.02,
            child: Image.asset(
              assetPath,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        ColoredBox(color: Colors.black.withValues(alpha: overlayOpacity)),
      ],
    );
  }
}

class FarmerGlassSurface extends StatelessWidget {
  const FarmerGlassSurface({
    super.key,
    required this.child,
    required this.color,
    this.borderRadius = BorderRadius.zero,
    this.blurSigma = 16,
    this.borderColor = const Color(0x33FFFFFF),
    this.boxShadow = const [],
  });

  final Widget child;
  final Color color;
  final BorderRadius borderRadius;
  final double blurSigma;
  final Color borderColor;
  final List<BoxShadow> boxShadow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: blurSigma,
            sigmaY: blurSigma,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: borderRadius,
              border: Border.all(color: borderColor),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
