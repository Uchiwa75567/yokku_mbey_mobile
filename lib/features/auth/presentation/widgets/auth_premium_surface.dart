import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/farmer_glass_surface.dart';

class AuthPremiumBackground extends StatelessWidget {
  const AuthPremiumBackground({
    this.overlayOpacity = 0.10,
    this.blurSigma = 0.45,
    super.key,
  });

  final double overlayOpacity;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    return FarmerGlassBackground(
      overlayOpacity: overlayOpacity,
      blurSigma: blurSigma,
    );
  }
}

class AuthPremiumCard extends StatelessWidget {
  const AuthPremiumCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.color = const Color(0xF5FAF9F6),
    this.borderColor = const Color(0xCCFFFFFF),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return FarmerGlassSurface(
      color: color,
      blurSigma: 20,
      borderRadius: BorderRadius.circular(24),
      borderColor: borderColor,
      boxShadow: const [
        BoxShadow(
          color: Color(0x3D071A0F),
          blurRadius: 28,
          offset: Offset(0, 12),
        ),
      ],
      child: Padding(padding: padding, child: child),
    );
  }
}

class AuthBrandMark extends StatelessWidget {
  const AuthBrandMark({
    this.compact = false,
    this.centered = false,
    this.onDark = false,
    super.key,
  });

  final bool compact;
  final bool centered;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 28 : 42,
          height: compact ? 28 : 42,
          decoration: BoxDecoration(
            color: onDark ? const Color(0xFFDDF3E4) : AppColors.forest,
            borderRadius: BorderRadius.circular(compact ? 99 : 10),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26063D22),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            Icons.eco_outlined,
            color: onDark ? AppColors.forest : AppColors.white,
            size: compact ? 16 : 23,
          ),
        ),
        SizedBox(width: compact ? 8 : 11),
        Text(
          'Yokku Mbey',
          style: TextStyle(
            color: onDark ? AppColors.white : AppColors.forestDeep,
            fontSize: compact ? 14 : 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.25,
          ),
        ),
      ],
    );

    return centered ? Center(child: content) : content;
  }
}
