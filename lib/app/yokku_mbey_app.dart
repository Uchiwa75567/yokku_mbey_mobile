import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import 'app_routes.dart';

class YokkuMbeyApp extends StatelessWidget {
  const YokkuMbeyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yokku Mbey',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routes: AppRoutes.routes,
      initialRoute: AppRoutes.splash,
      builder: (context, child) {
        return ColoredBox(
          color: AppColors.forestDeep,
          child: SafeArea(
            top: true,
            bottom: false,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
