import 'package:flutter/material.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/verification_page.dart';
import '../features/harvest_publication/presentation/pages/harvest_publication_page.dart';
import '../features/home/presentation/pages/profile_home_page.dart';
import '../features/profile_selection/presentation/pages/profile_selection_page.dart';
import '../features/splash/presentation/pages/splash_page.dart';

abstract final class AppRoutes {
  static const String splash = SplashPage.routeName;
  static const String login = LoginPage.routeName;
  static const String verification = VerificationPage.routeName;
  static const String profileSelection = ProfileSelectionPage.routeName;
  static const String home = ProfileHomePage.routeName;
  static const String publishHarvest = HarvestPublicationPage.routeName;

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (_) => const SplashPage(),
      login: (_) => const LoginPage(),
      verification: (_) => const VerificationPage(),
      profileSelection: (_) => const ProfileSelectionPage(),
      home: ProfileHomePage.fromRoute,
      publishHarvest: (_) => const HarvestPublicationPage(),
    };
  }
}
