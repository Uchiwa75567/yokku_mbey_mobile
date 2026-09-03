import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/features/buyer_favorites/presentation/pages/buyer_favorites_page.dart';
import 'package:yokku_mbey/features/buyer_products/presentation/pages/buyer_product_detail_page.dart';

void main() {
  testWidgets('shows favorites and opens a product', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        routes: {
          BuyerProductDetailPage.routeName: BuyerProductDetailPage.fromRoute,
        },
        home: BuyerFavoritesPage(),
      ),
    );

    expect(find.text('Favoris et alertes'), findsOneWidget);
    expect(find.text('Tomate fraîche'), findsOneWidget);
    expect(find.text('Oignon local'), findsOneWidget);
    expect(find.text('Pomme de terre'), findsOneWidget);

    await tester.tap(find.text('Voir le produit').first);
    await tester.pumpAndSettle();

    expect(find.byType(BuyerProductDetailPage), findsOneWidget);
    expect(find.text('400 FCFA / kg'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switches between alerts and followed producers', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: BuyerFavoritesPage()),
    );

    await tester.tap(find.text('Alertes prix'));
    await tester.pump();
    expect(find.textContaining('Alerte à 350 FCFA/kg'), findsOneWidget);

    await tester.tap(find.text('Producteurs suivis'));
    await tester.pump();
    expect(find.text('Ibrahima Ndiaye'), findsOneWidget);
    expect(find.text('Awa Diop'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('removes a favorite', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BuyerFavoritesPage()),
    );

    await tester.tap(find.byTooltip('Retirer des favoris').first);
    await tester.pump();

    expect(find.text('Tomate fraîche'), findsNothing);
    expect(find.textContaining('retiré des favoris'), findsOneWidget);
  });
}
