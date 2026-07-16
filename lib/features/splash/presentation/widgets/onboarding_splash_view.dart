import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../domain/entities/onboarding_slide.dart';
import '../../domain/entities/onboarding_slides.dart';

class OnboardingSplashView extends StatefulWidget {
  const OnboardingSplashView({super.key});

  @override
  State<OnboardingSplashView> createState() => _OnboardingSplashViewState();
}

class _OnboardingSplashViewState extends State<OnboardingSplashView> {
  int _currentIndex = 0;

  void _goToNextSlide() {
    if (_currentIndex >= OnboardingSlides.items.length - 1) {
      Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
      return;
    }

    setState(() => _currentIndex += 1);
  }

  void _skipOnboarding() {
    Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final slide = OnboardingSlides.items[_currentIndex];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: ColoredBox(
        color: AppColors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 30, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _OnboardingHeader(
                    key: ValueKey('header-$_currentIndex'),
                    slide: slide,
                  ),
                ),
                const SizedBox(height: 44),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _OnboardingImage(
                      key: ValueKey(slide.imageAsset),
                      slide: slide,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _PageIndicator(
                  currentIndex: _currentIndex,
                  itemCount: 3,
                ),
                const SizedBox(height: 22),
                _NextButton(onPressed: _goToNextSlide),
                const SizedBox(height: 26),
                _SkipButton(onPressed: _skipOnboarding),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({
    required this.slide,
    super.key,
  });

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          slide.title,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.12,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          slide.description,
          style: const TextStyle(
            color: AppColors.mutedInk,
            fontSize: 18,
            fontWeight: FontWeight.w400,
            height: 1.45,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _OnboardingImage extends StatelessWidget {
  const _OnboardingImage({
    required this.slide,
    super.key,
  });

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OverflowBox(
          maxWidth: constraints.maxWidth * slide.imageWidthFactor,
          maxHeight: constraints.maxHeight * slide.imageHeightFactor,
          child: Image.asset(
            slide.imageAsset,
            width: constraints.maxWidth * slide.imageWidthFactor,
            height: constraints.maxHeight * slide.imageHeightFactor,
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        );
      },
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.currentIndex,
    required this.itemCount,
  });

  final int currentIndex;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
          child: _Dot(isActive: index == currentIndex),
        );
      }),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({this.isActive = false});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 10,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isActive ? AppColors.leaf : AppColors.inactiveDot,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.leaf,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        child: const Text('Suivant'),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.ink,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
      child: const Text('Passer'),
    );
  }
}
