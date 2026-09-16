import 'package:flutter/material.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class SplashBackgroundImage extends StatelessWidget {
  const SplashBackgroundImage({super.key});
  @override
  Widget build(BuildContext context) => const ColoredBox(
      color: AppColors.forestDeep,
      child: SizedBox.expand(
          child: Image(
        image: AssetImage(AppAssets.splashScreen),
        fit: BoxFit.contain,
        alignment: Alignment.center,
        semanticLabel: 'Yokku Mbey. L’agriculture, notre richesse ensemble.',
      )));
}
