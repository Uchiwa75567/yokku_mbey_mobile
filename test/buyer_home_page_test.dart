import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/features/buyer/presentation/buyer_journey_pages.dart';
import 'package:yokku_mbey/features/profile_selection/domain/entities/user_profile_type.dart';
import 'support/marketplace_test_app.dart';

void main() {
  testWidgets('buyer home matches the approved light market layout',
      (tester) async {
    _phone(tester);
    await tester.pumpWidget(
        marketplaceTestApp(store: testStore(UserProfileType.buyer)));
    expect(find.text('Yokku Mbey'), findsOneWidget);
    expect(find.text('Espace acheteur'), findsOneWidget);
    expect(find.text('Produits disponibles'), findsOneWidget);
    expect(find.text('Tomate fraîche'), findsOneWidget);
    expect(find.text('Oignon local'), findsOneWidget);
    expect(find.text('400 FCFA / kg'), findsOneWidget);
    expect(find.byType(ProductGrid), findsOneWidget);
    expect(find.text('Marché'), findsOneWidget);
    expect(find.text('Achats'), findsOneWidget);
    expect(find.bySemanticsLabel('Publier une demande'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('home search filters products and navigation opens the market',
      (tester) async {
    _phone(tester);
    await tester.pumpWidget(
        marketplaceTestApp(store: testStore(UserProfileType.buyer)));
    await tester.enterText(find.byType(TextField), 'oignon');
    await tester.pumpAndSettle();
    expect(find.text('Tomate fraîche'), findsNothing);
    expect(find.text('Oignon local'), findsOneWidget);
    await tester.tap(find.text('Marché'));
    await tester.pumpAndSettle();
    expect(find.byType(BuyerMarketPage), findsOneWidget);
    expect(find.text('Le marché'), findsOneWidget);
  });
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
