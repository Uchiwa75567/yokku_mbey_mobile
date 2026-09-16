import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/marketplace_test_app.dart';
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

    expect(find.text('Yokku Mbey'), findsOneWidget);
    expect(find.text('Mon activité agricole'), findsOneWidget);
    expect(find.text('Ajouter une récolte'), findsOneWidget);
    expect(find.text('Tomates fraîches'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsWidgets);
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

    expect(find.text('Yokku Mbey'), findsOneWidget);
    expect(find.text('Mon activité agricole'), findsOneWidget);
  });

  testWidgets('displays buyer home actions', (tester) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileHomePage(profileType: UserProfileType.buyer),
      ),
    );

    expect(find.text('Yokku Mbey'), findsOneWidget);
    expect(find.text('Espace acheteur'), findsOneWidget);
    expect(find.text('Produits disponibles'), findsOneWidget);
    expect(find.text('Tomate fraîche'), findsOneWidget);
    expect(find.text('Oignon local'), findsOneWidget);
    expect(find.text('Accueil'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsWidgets);
    expect(find.byType(ListView), findsNothing);
    expect(find.byType(GridView), findsNothing);
  });

  testWidgets('displays provider home actions', (tester) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      marketplaceTestApp(store: testStore(UserProfileType.provider)),
    );

    expect(find.text('Bonjour prestataire'), findsOneWidget);
    expect(find.text('Ajouter un service'), findsOneWidget);
    expect(find.text('Voir les demandes'), findsOneWidget);
    expect(find.text('Gérer mes contacts'), findsOneWidget);
  });

  testWidgets('displays investor home actions', (tester) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      marketplaceTestApp(store: testStore(UserProfileType.investor)),
    );

    expect(find.text('Bonjour partenaire'), findsOneWidget);
    expect(find.text('Voir les projets'), findsOneWidget);
    expect(find.text('Mes intentions'), findsOneWidget);
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
