import 'package:flutter/material.dart';

import 'app_routes.dart';
import '../core/theme/app_theme.dart';

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
    );
  }
}
