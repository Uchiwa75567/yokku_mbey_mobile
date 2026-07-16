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
    expect(find.textContaining('YOKKU MBEY'), findsOneWidget);
    expect(find.text('Suivant'), findsOneWidget);
    expect(find.text('Passer'), findsOneWidget);
  });

  testWidgets('shows the second onboarding slide after tapping next', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashPage()));

    await tester.pump(SplashPage.firstStageDuration);
    await tester.pump(SplashPage.transitionDuration);
    await tester.tap(find.text('Suivant'));
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
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suivant'));
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
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Bienvenue !'), findsOneWidget);
  });
}
