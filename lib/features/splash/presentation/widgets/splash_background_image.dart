import 'package:flutter/material.dart';

import '../../../../core/theme/app_assets.dart';

class SplashBackgroundImage extends StatelessWidget {
  const SplashBackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: Image(
        image: AssetImage(AppAssets.splashScreen),
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),
    );
  }
}
