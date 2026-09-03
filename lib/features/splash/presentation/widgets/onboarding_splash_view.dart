import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_assets.dart';
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
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _OnboardingBackground(),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxHeight < 720 ||
                          constraints.maxWidth < 350;
                      final scrollable = constraints.maxHeight < 560;

                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          compact ? 18 : 24,
                          compact ? 10 : 12,
                          compact ? 18 : 24,
                          compact ? 14 : 20,
                        ),
                        child: scrollable
                            ? SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                child: _ScrollableOnboardingLayout(
                                  currentIndex: _currentIndex,
                                  slide: slide,
                                  compact: compact,
                                  onNext: _goToNextSlide,
                                  onSkip: _skipOnboarding,
                                ),
                              )
                            : _OnboardingLayout(
                                currentIndex: _currentIndex,
                                slide: slide,
                                compact: compact,
                                onNext: _goToNextSlide,
                                onSkip: _skipOnboarding,
                              ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingBackground extends StatelessWidget {
  const _OnboardingBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          AppAssets.onboardingBackground,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          excludeFromSemantics: true,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x1A000000),
                Color(0x52000000),
                Color(0xC9000000),
                Color(0xFF000000),
              ],
              stops: [0, 0.38, 0.72, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingLayout extends StatelessWidget {
  const _OnboardingLayout({
    required this.currentIndex,
    required this.slide,
    required this.compact,
    required this.onNext,
    required this.onSkip,
  });

  final int currentIndex;
  final OnboardingSlide slide;
  final bool compact;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: _SkipButton(onPressed: onSkip),
        ),
        SizedBox(height: compact ? 8 : 12),
        Expanded(
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: _fadeScaleTransition,
              child: _StageIcon(
                key: ValueKey(currentIndex),
                index: currentIndex,
                compact: compact,
              ),
            ),
          ),
        ),
        _OnboardingBottomContent(
          currentIndex: currentIndex,
          slide: slide,
          compact: compact,
          onNext: onNext,
        ),
      ],
    );
  }
}

class _ScrollableOnboardingLayout extends StatelessWidget {
  const _ScrollableOnboardingLayout({
    required this.currentIndex,
    required this.slide,
    required this.compact,
    required this.onNext,
    required this.onSkip,
  });

  final int currentIndex;
  final OnboardingSlide slide;
  final bool compact;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: _SkipButton(onPressed: onSkip),
        ),
        const SizedBox(height: 18),
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: _fadeScaleTransition,
            child: _StageIcon(
              key: ValueKey(currentIndex),
              index: currentIndex,
              compact: true,
            ),
          ),
        ),
        const SizedBox(height: 22),
        _OnboardingBottomContent(
          currentIndex: currentIndex,
          slide: slide,
          compact: true,
          onNext: onNext,
        ),
      ],
    );
  }
}

Widget _fadeScaleTransition(Widget child, Animation<double> animation) {
  final scale = Tween<double>(begin: 0.96, end: 1).animate(animation);

  return FadeTransition(
    opacity: animation,
    child: ScaleTransition(scale: scale, child: child),
  );
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Passer l’onboarding',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: Colors.white.withValues(alpha: 0.10),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(99),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: const Text(
                  'Passer',
                  style: TextStyle(
                    color: Color(0xF2FFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StageIcon extends StatelessWidget {
  const _StageIcon({
    required this.index,
    required this.compact,
    super.key,
  });

  final int index;
  final bool compact;

  IconData get _icon => switch (index) {
        0 => Icons.eco_outlined,
        1 => Icons.shopping_basket_outlined,
        _ => Icons.handyman_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final size = compact ? 88.0 : 112.0;

    return Semantics(
      image: true,
      label: switch (index) {
        0 => 'Agriculture',
        1 => 'Produits agricoles',
        _ => 'Services agricoles',
      },
      child: SizedBox.square(
        dimension: size,
        child: ClipOval(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.26),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.08),
                    blurRadius: 38,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _icon,
                color: const Color(0xFFA2F5B6),
                size: compact ? 42 : 52,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingBottomContent extends StatelessWidget {
  const _OnboardingBottomContent({
    required this.currentIndex,
    required this.slide,
    required this.compact,
    required this.onNext,
  });

  final int currentIndex;
  final OnboardingSlide slide;
  final bool compact;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PageIndicator(
          currentIndex: currentIndex,
          itemCount: OnboardingSlides.items.length,
        ),
        SizedBox(height: compact ? 22 : 32),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final offset = Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(animation);

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offset, child: child),
            );
          },
          child: _SlideCopy(
            key: ValueKey(currentIndex),
            slide: slide,
            highlightBrand: currentIndex == 0,
            compact: compact,
          ),
        ),
        SizedBox(height: compact ? 22 : 34),
        _NextButton(onPressed: onNext),
      ],
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
    return Semantics(
      label: 'Étape ${currentIndex + 1} sur $itemCount',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(itemCount, (index) {
          final active = index == currentIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: active ? 30 : 8,
            height: 4,
            margin: EdgeInsets.only(left: index == 0 ? 0 : 7),
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFFA2F5B6)
                  : Colors.white.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(99),
              boxShadow: active
                  ? const [
                      BoxShadow(
                        color: Color(0x66A2F5B6),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }
}

class _SlideCopy extends StatelessWidget {
  const _SlideCopy({
    required this.slide,
    required this.highlightBrand,
    required this.compact,
    super.key,
  });

  final OnboardingSlide slide;
  final bool highlightBrand;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final titleBreak = slide.title.indexOf('\n');
    final titlePrefix = titleBreak == -1
        ? slide.title
        : slide.title.substring(0, titleBreak + 1);
    final titleHighlight =
        titleBreak == -1 ? '' : slide.title.substring(titleBreak + 1);
    final titleStyle = TextStyle(
      color: Colors.white,
      fontSize: compact ? 25 : 32,
      fontWeight: FontWeight.w800,
      height: 1.08,
      letterSpacing: compact ? -0.45 : -0.75,
      shadows: const [
        Shadow(color: Color(0x99000000), blurRadius: 8),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (highlightBrand)
          Text.rich(
            TextSpan(
              style: titleStyle,
              children: [
                TextSpan(text: titlePrefix),
                TextSpan(
                  text: titleHighlight,
                  style: const TextStyle(color: Color(0xFFA2F5B6)),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          )
        else
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: titleStyle,
          ),
        SizedBox(height: compact ? 12 : 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 350),
          child: Text(
            slide.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: compact ? 12.5 : 14.5,
              fontWeight: FontWeight.w400,
              height: 1.5,
              shadows: const [
                Shadow(color: Color(0xB3000000), blurRadius: 6),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Suivant',
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF006B38), Color(0xFF43C978)],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0x29FFFFFF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66006131),
              blurRadius: 26,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(15),
            child: const SizedBox(
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SUIVANT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.25,
                    ),
                  ),
                  SizedBox(width: 11),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
