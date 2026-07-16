import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/app/yokku_mbey_app.dart';
import 'package:yokku_mbey/features/splash/presentation/pages/splash_page.dart';
import 'package:yokku_mbey/features/splash/presentation/widgets/onboarding_splash_view.dart';

void main() {
  testWidgets('starts on the splash page', (tester) async {
    await tester.pumpWidget(const YokkuMbeyApp());

    expect(find.byType(SplashPage), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('shows the second splash after the transition', (tester) async {
    await tester.pumpWidget(const YokkuMbeyApp());

    await tester.pump(SplashPage.firstStageDuration);
    await tester.pump(SplashPage.transitionDuration);

    expect(find.byType(OnboardingSplashView), findsOneWidget);
  });
}
