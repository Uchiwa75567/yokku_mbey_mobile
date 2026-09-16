import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/app/app_routes.dart';
import 'package:yokku_mbey/features/harvest_publication/presentation/pages/harvest_publication_page.dart';
import 'package:yokku_mbey/features/home/presentation/pages/profile_home_page.dart';
import 'package:yokku_mbey/features/profile_selection/domain/entities/user_profile_type.dart';

void main() {
  testWidgets('opens harvest publication from farmer home quick action', (
    tester,
  ) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          HarvestPublicationPage.routeName: (_) =>
              const HarvestPublicationPage(),
        },
        home: const ProfileHomePage(profileType: UserProfileType.farmer),
      ),
    );

    await tester.ensureVisible(find.text('Ajouter une récolte'));
    await tester.tap(find.text('Ajouter une récolte'));
    await tester.pumpAndSettle();

    expect(find.byType(HarvestPublicationPage), findsOneWidget);
    expect(find.text('Publier une récolte'), findsOneWidget);
    expect(find.text('Étape 1 sur 3'), findsOneWidget);
    expect(find.text("Ajouter jusqu'à 5 photos"), findsOneWidget);
    expect(find.text('Nom du produit *'), findsOneWidget);
  });

  testWidgets('moves through harvest publication steps', (tester) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        routes: AppRoutes.routes,
        initialRoute: HarvestPublicationPage.routeName,
      ),
    );

    await tester.ensureVisible(find.text('Continuer'));
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Étape 2 sur 3'), findsOneWidget);
    expect(find.text('Quantité et prix'), findsOneWidget);
    expect(find.text('Localisation'), findsOneWidget);

    await tester.ensureVisible(find.text('Continuer'));
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Disponibilité'), findsOneWidget);
    expect(find.text('Étape 3 sur 3'), findsOneWidget);
    expect(find.text('Disponible maintenant'), findsOneWidget);
    expect(find.text('Mode de récupération'), findsOneWidget);

    await tester.ensureVisible(find.text('Disponible prochainement'));
    await tester.tap(find.text('Disponible prochainement'));
    await tester.pumpAndSettle();

    expect(find.text('Période estimée'), findsOneWidget);
    expect(find.text('DATE DE DÉBUT *'), findsOneWidget);
    expect(find.text('Autoriser les pré-réservations'), findsOneWidget);
    expect(find.text("Pourcentage d'acompte"), findsOneWidget);
    expect(find.text('Publier la récolte'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('date-field-DATE DE DÉBUT *')));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    Navigator.of(tester.element(find.byType(DatePickerDialog))).pop();
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('deposit-percent-input')),
      '30 %',
    );
    await tester.pump();
    expect(find.text('30 %'), findsOneWidget);

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(find.byType(GridView), findsNothing);
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
