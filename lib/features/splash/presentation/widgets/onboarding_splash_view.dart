import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../domain/entities/onboarding_slides.dart';

class OnboardingSplashView extends StatefulWidget {
  const OnboardingSplashView({super.key});
  @override
  State<OnboardingSplashView> createState() => _OnboardingSplashViewState();
}

class _OnboardingSplashViewState extends State<OnboardingSplashView> {
  int _currentIndex = 0;
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _skip() =>
      Navigator.of(context).pushReplacementNamed(LoginPage.routeName);

  void _next() {
    if (_currentIndex == OnboardingSlides.items.length - 1) {
      _skip();
      return;
    }
    _controller.nextPage(
        duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
  }

  void _previous() => _controller.previousPage(
      duration: const Duration(milliseconds: 280), curve: Curves.easeOut);

  @override
  Widget build(BuildContext context) => ColoredBox(
      color: Colors.white,
      child: SafeArea(
          child: Center(
              child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 16, 4),
              child: Row(children: [
                const Expanded(
                    child: Text('Yokku Mbey',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.leaf))),
                TextButton(onPressed: _skip, child: const Text('Passer')),
              ])),
          Expanded(
              child: PageView.builder(
            controller: _controller,
            itemCount: OnboardingSlides.items.length,
            onPageChanged: (v) => setState(() => _currentIndex = v),
            itemBuilder: (context, index) {
              final slide = OnboardingSlides.items[index];
              final lines = slide.title.split('\n');
              return LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraints.maxHeight),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: SizedBox(
                                    height: (constraints.maxHeight * .57)
                                        .clamp(170.0, 400.0),
                                    child: Image.asset(slide.imageAsset,
                                        fit: BoxFit.contain,
                                        semanticLabel: slide.label)),
                              ),
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(24, 20, 24, 16),
                                  child: Column(children: [
                                    Text(slide.label,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.softInk)),
                                    const SizedBox(height: 10),
                                    Text.rich(
                                        TextSpan(children: [
                                          TextSpan(text: lines.first),
                                          if (lines.length > 1)
                                            TextSpan(
                                                text:
                                                    '\n${lines.skip(1).join('\n')}',
                                                style: const TextStyle(
                                                    color: AppColors.leaf)),
                                        ]),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            height: 1.15,
                                            color: AppColors.ink)),
                                    const SizedBox(height: 14),
                                    ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 360),
                                      child: Text(slide.description,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: AppColors.softInk,
                                              height: 1.5)),
                                    ),
                                  ])),
                            ],
                          ),
                        ),
                      ));
            },
          )),
          Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Column(children: [
                Semantics(
                    label:
                        'Étape ${_currentIndex + 1} sur ${OnboardingSlides.items.length}',
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                            OnboardingSlides.items.length,
                            (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 240),
                                width: 28,
                                height: 4,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                    color: i == _currentIndex
                                        ? AppColors.leaf
                                        : AppColors.border,
                                    borderRadius: BorderRadius.circular(2)))))),
                const SizedBox(height: 20),
                Row(children: [
                  SizedBox.square(
                      dimension: 52,
                      child: IconButton.outlined(
                          tooltip: 'Étape précédente',
                          onPressed: _currentIndex == 0 ? null : _previous,
                          style: IconButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              side: const BorderSide(color: AppColors.border)),
                          icon: const Icon(Icons.arrow_back, size: 20))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: FilledButton.icon(
                          onPressed: _next,
                          icon: const Icon(Icons.arrow_forward, size: 20),
                          label: Text(
                              _currentIndex == OnboardingSlides.items.length - 1
                                  ? 'Commencer'
                                  : 'Suivant'))),
                ]),
                const SizedBox(height: 4),
                TextButton(onPressed: _skip, child: const Text('Se connecter')),
              ])),
        ]),
      ))));
}
