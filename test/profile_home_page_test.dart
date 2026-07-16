import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/features/home/presentation/pages/profile_home_page.dart';
import 'package:yokku_mbey/features/profile_selection/domain/entities/user_profile_type.dart';

void main() {
  testWidgets('displays farmer home actions', (tester) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileHomePage(profileType: UserProfileType.farmer),
      ),
    );

    expect(find.text('Bonjour, Ibrahima'), findsOneWidget);
    expect(find.text('Solde disponible'), findsOneWidget);
    expect(find.text('1 250 000 FCFA'), findsOneWidget);
    expect(find.text('Récoltes actives'), findsOneWidget);
    expect(find.text('Ajouter\nune récolte'), findsOneWidget);
    expect(find.text('Actions rapides'), findsOneWidget);
    expect(find.text('Dernière réservation'), findsOneWidget);
    expect(find.text('Tomate fraîche • 200 kg'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.byType(ListView), findsNothing);
    expect(find.byType(GridView), findsNothing);
  });

  testWidgets('defaults direct home route to farmer dashboard', (tester) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      const MaterialApp(
        routes: {ProfileHomePage.routeName: ProfileHomePage.fromRoute},
        initialRoute: ProfileHomePage.routeName,
      ),
    );

    expect(find.text('Bonjour, Ibrahima'), findsOneWidget);
    expect(find.text('Solde disponible'), findsOneWidget);
  });

  testWidgets('displays buyer home actions', (tester) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileHomePage(profileType: UserProfileType.buyer),
      ),
    );

    expect(find.text('Bonjour, Amadou 👋'), findsOneWidget);
    expect(find.text('Produits disponibles maintenant'), findsOneWidget);
    expect(find.text('Tomate fraiche'), findsOneWidget);
    expect(find.text('Oignon local'), findsOneWidget);
    expect(find.text('Catégories populaires'), findsOneWidget);
    expect(find.text('Accueil'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.byType(ListView), findsNothing);
    expect(find.byType(GridView), findsNothing);
  });

  testWidgets('displays provider home actions', (tester) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileHomePage(profileType: UserProfileType.provider),
      ),
    );

    expect(find.text('Bonjour prestataire'), findsOneWidget);
    expect(find.text('Ajouter un service'), findsOneWidget);
    expect(find.text('Voir les demandes'), findsOneWidget);
    expect(find.text('Gérer mes contacts'), findsOneWidget);
  });

  testWidgets('displays investor home actions', (tester) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileHomePage(profileType: UserProfileType.investor),
      ),
    );

    expect(find.text('Bonjour partenaire'), findsOneWidget);
    expect(find.text('Voir les projets'), findsOneWidget);
    expect(find.text('Soutenir une activité'), findsOneWidget);
    expect(find.text('Suivre les impacts'), findsOneWidget);
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
