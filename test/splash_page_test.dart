import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/app/app_routes.dart';
import 'package:yokku_mbey/core/theme/app_assets.dart';
import 'package:yokku_mbey/features/auth/presentation/pages/login_page.dart';
import 'package:yokku_mbey/features/splash/presentation/pages/splash_page.dart';
import 'package:yokku_mbey/features/splash/presentation/widgets/onboarding_splash_view.dart';

void main() {
  testWidgets('displays the first splash visual asset', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashPage()));

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, const AssetImage(AppAssets.splashScreen));
    expect(find.byType(SplashPage), findsOneWidget);
  });

  testWidgets('keeps the first splash visible for about five seconds', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashPage()));

    await tester
        .pump(SplashPage.firstStageDuration - const Duration(milliseconds: 1));

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, const AssetImage(AppAssets.splashScreen));
    expect(find.byType(OnboardingSplashView), findsNothing);
  });

  testWidgets('animates from the first splash to the onboarding splash', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashPage()));

    await tester.pump(SplashPage.firstStageDuration);
    await tester.pump(SplashPage.transitionDuration);

    expect(find.byType(OnboardingSplashView), findsOneWidget);
    expect(
      find.text('Bienvenue sur\nYOKKU MBEY', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('SUIVANT'), findsOneWidget);
    expect(find.text('Passer'), findsOneWidget);

    final background = tester.widget<Image>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image == const AssetImage(AppAssets.onboardingBackground),
      ),
    );
    expect(
      background.image,
      const AssetImage(AppAssets.onboardingBackground),
    );
  });

  testWidgets('shows the second onboarding slide after tapping next', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashPage()));

    await tester.pump(SplashPage.firstStageDuration);
    await tester.pump(SplashPage.transitionDuration);
    await tester.tap(find.text('SUIVANT'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Trouvez facilement les'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Connectez-vous avec les producteurs'),
      findsOneWidget,
    );
  });

  testWidgets('shows the third onboarding slide after tapping next twice', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashPage()));

    await tester.pump(SplashPage.firstStageDuration);
    await tester.pump(SplashPage.transitionDuration);
    await tester.tap(find.text('SUIVANT'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SUIVANT'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Propose vos services'),
      findsOneWidget,
    );
    expect(
      find.textContaining("Rejoignez des milliers d'agriculteurs"),
      findsOneWidget,
    );
  });

  testWidgets('opens login page after the last onboarding slide', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: AppRoutes.routes,
        initialRoute: SplashPage.routeName,
      ),
    );

    await tester.pump(SplashPage.firstStageDuration);
    await tester.pump(SplashPage.transitionDuration);
    await tester.tap(find.text('SUIVANT'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SUIVANT'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SUIVANT'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Bienvenue !'), findsOneWidget);
  });

  testWidgets('skips the onboarding directly to login', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          LoginPage.routeName: (_) => const LoginPage(),
        },
        home: const OnboardingSplashView(),
      ),
    );

    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(OnboardingSplashView), findsNothing);
  });

  testWidgets('stays usable on a compact phone viewport', (tester) async {
    tester.view.physicalSize = const Size(320, 520);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(home: OnboardingSplashView()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('SUIVANT'), findsOneWidget);
    expect(find.text('Passer'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
