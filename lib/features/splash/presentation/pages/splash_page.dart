import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_assets.dart';
import '../../domain/entities/splash_stage.dart';
import '../widgets/onboarding_splash_view.dart';
import '../widgets/splash_background_image.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static const String routeName = '/';
  static const Duration firstStageDuration = Duration(seconds: 5);
  static const Duration transitionDuration = Duration(milliseconds: 850);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  SplashStage _stage = SplashStage.welcome;
  Timer? _stageTimer;
  bool _onboardingBackgroundCached = false;

  @override
  void initState() {
    super.initState();
    _stageTimer = Timer(SplashPage.firstStageDuration, _showBrandStage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_onboardingBackgroundCached) {
      return;
    }

    _onboardingBackgroundCached = true;
    precacheImage(
      const AssetImage(AppAssets.onboardingBackground),
      context,
    );
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    super.dispose();
  }

  void _showBrandStage() {
    if (!mounted) {
      return;
    }

    setState(() => _stage = SplashStage.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: SplashPage.transitionDuration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final scale = Tween<double>(begin: 1.04, end: 1).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: scale,
              child: child,
            ),
          );
        },
        child: switch (_stage) {
          SplashStage.welcome => const SplashBackgroundImage(
              key: ValueKey(SplashStage.welcome),
            ),
          SplashStage.onboarding => const OnboardingSplashView(
              key: ValueKey(SplashStage.onboarding),
            ),
        },
      ),
    );
  }
}
