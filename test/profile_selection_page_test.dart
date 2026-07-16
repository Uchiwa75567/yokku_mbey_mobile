import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/app/app_routes.dart';
import 'package:yokku_mbey/features/home/presentation/pages/profile_home_page.dart';
import 'package:yokku_mbey/features/profile_selection/presentation/pages/profile_selection_page.dart';
import 'package:yokku_mbey/features/profile_selection/presentation/widgets/profile_option_tile.dart';

void main() {
  testWidgets('displays the profile selection screen content', (tester) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(const MaterialApp(home: ProfileSelectionPage()));

    expect(find.text('Vous êtes ?'), findsOneWidget);
    expect(find.textContaining('Choisissez votre profil'), findsOneWidget);
    expect(find.byType(ProfileOptionTile), findsNWidgets(4));
    expect(find.text('Agriculteur'), findsOneWidget);
    expect(find.text('Acheteur'), findsOneWidget);
    expect(find.text('Prestataire'), findsOneWidget);
    expect(find.text('Investisseur / ONG'), findsOneWidget);
    expect(find.text('Suivant'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
  });

  testWidgets('fits the profile selection screen on phone height', (
    tester,
  ) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(const MaterialApp(home: ProfileSelectionPage()));

    expect(find.text('Suivant'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
  });

  testWidgets('opens the selected profile home page', (tester) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        routes: AppRoutes.routes,
        initialRoute: ProfileSelectionPage.routeName,
      ),
    );

    await tester.tap(find.text('Agriculteur'));
    await tester.pump();
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileHomePage), findsOneWidget);
    expect(find.text('Solde disponible'), findsOneWidget);
  });

  testWidgets('opens the buyer marketplace home page', (tester) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        routes: AppRoutes.routes,
        initialRoute: ProfileSelectionPage.routeName,
      ),
    );

    await tester.tap(find.text('Acheteur'));
    await tester.pump();
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();

    expect(find.text('Produits disponibles maintenant'), findsOneWidget);
    expect(find.text('Tomate fraiche'), findsOneWidget);
  });
}

void _setPhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 825);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
