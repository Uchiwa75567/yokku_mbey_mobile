import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/app/app_routes.dart';
import 'package:yokku_mbey/core/theme/app_theme.dart';
import 'package:yokku_mbey/core/theme/app_assets.dart';
import 'package:yokku_mbey/features/splash/presentation/pages/splash_page.dart';
import 'package:yokku_mbey/features/splash/presentation/widgets/onboarding_splash_view.dart';
import 'package:yokku_mbey/features/auth/presentation/pages/login_page.dart';

void main() {
  Future<void> show(WidgetTester tester,
      {Size size = const Size(390, 844)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, routes: AppRoutes.routes, initialRoute: '/'));
  }

  Future<void> onboarding(WidgetTester tester) async {
    await tester.pump(SplashPage.firstStageDuration);
    await tester.pumpAndSettle();
  }

  testWidgets('splash preserves the original artwork then opens onboarding',
      (tester) async {
    await show(tester);
    final artwork = find.image(const AssetImage(AppAssets.splashScreen));
    expect(artwork, findsOneWidget);
    expect(tester.widget<Image>(artwork).fit, BoxFit.contain);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(SplashPage.firstStageDuration, lessThan(const Duration(seconds: 1)));
    await onboarding(tester);
    expect(artwork, findsNothing);
    expect(find.byType(OnboardingSplashView), findsOneWidget);
    expect(find.text('Faisons grandir\nvotre activité.'), findsOneWidget);
  });
  testWidgets('onboarding advances and opens login after the last slide',
      (tester) async {
    await show(tester);
    await onboarding(tester);
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Le marché,\nprès de chez vous.'), findsOneWidget);
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(
        find.text('Des savoir-faire.\nDes projets d’avenir.'), findsOneWidget);
    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
  });
  testWidgets('onboarding can be skipped', (tester) async {
    await show(tester);
    await onboarding(tester);
    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
  });
  testWidgets('onboarding goes back and keeps the first step bounded',
      (tester) async {
    await show(tester);
    await onboarding(tester);
    final back = find.byWidgetPredicate(
        (w) => w is IconButton && w.tooltip == 'Étape précédente');
    expect(tester.widget<IconButton>(back).onPressed, isNull);
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(tester.widget<IconButton>(back).onPressed, isNotNull);
    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(find.text('Faisons grandir\nvotre activité.'), findsOneWidget);
    expect(tester.widget<IconButton>(back).onPressed, isNull);
  });
  testWidgets('onboarding provides direct access to login', (tester) async {
    await show(tester);
    await onboarding(tester);
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
  });
  testWidgets('onboarding supports swiping', (tester) async {
    await show(tester);
    await onboarding(tester);
    await tester.drag(find.byType(PageView), const Offset(-390, 0));
    await tester.pumpAndSettle();
    expect(find.text('Le marché,\nprès de chez vous.'), findsOneWidget);
  });
  testWidgets('onboarding fits a compact viewport', (tester) async {
    await show(tester, size: const Size(320, 568));
    await onboarding(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Suivant').hitTestable(), findsOneWidget);
  });
}
