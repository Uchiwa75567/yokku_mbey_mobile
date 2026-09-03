import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/features/buyer_products/presentation/pages/buyer_products_page.dart';
import 'package:yokku_mbey/features/home/presentation/pages/buyer_home_page.dart';

void main() {
  testWidgets('matches the premium Stitch buyer home structure', (
    tester,
  ) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          BuyerProductsPage.routeName: (_) => const BuyerProductsPage(),
        },
        home: const BuyerHomePage(),
      ),
    );

    expect(find.text('Bonjour,'), findsOneWidget);
    expect(find.text('Amadou'), findsOneWidget);
    expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
    expect(find.bySemanticsLabel('Rechercher un produit'), findsOneWidget);
    expect(find.bySemanticsLabel('Filtrer les produits'), findsOneWidget);
    expect(find.text('Catégories'), findsOneWidget);
    expect(find.text('Légumes'), findsOneWidget);
    expect(find.text('Fruits'), findsOneWidget);
    expect(find.text('Céréales'), findsOneWidget);
    expect(find.text('Tubercules'), findsOneWidget);
    expect(find.text('Produits disponibles'), findsOneWidget);
    expect(find.text('Tomates Fraîches'), findsOneWidget);
    expect(find.text('450 FCFA/kg'), findsOneWidget);
    expect(find.text('Niayes, Sénégal'), findsOneWidget);
    expect(find.text('Oignons Locaux'), findsOneWidget);
    expect(find.text('300 FCFA/kg'), findsOneWidget);
    expect(find.text('Podor, Sénégal'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);
    expect(find.bySemanticsLabel('Action principale'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens the product catalogue from premium search', (
    tester,
  ) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          BuyerProductsPage.routeName: (_) => const BuyerProductsPage(),
        },
        home: const BuyerHomePage(),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Rechercher un produit'));
    await tester.pumpAndSettle();

    expect(find.byType(BuyerProductsPage), findsOneWidget);
    expect(find.text('Trouvez des produits disponibles'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _setPhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
