import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/features/buyer_favorites/presentation/pages/buyer_favorites_page.dart';
import 'package:yokku_mbey/features/buyer_needs/presentation/pages/publish_buyer_need_page.dart';
import 'package:yokku_mbey/features/buyer_products/presentation/pages/buyer_empty_search_page.dart';
import 'package:yokku_mbey/features/buyer_products/presentation/pages/buyer_products_page.dart';
import 'package:yokku_mbey/features/buyer_purchases/presentation/pages/buyer_purchases_page.dart';

void main() {
  Future<void> usePhoneSize(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('une recherche validée affiche l’état sans résultat', (
    tester,
  ) async {
    await usePhoneSize(tester);
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          BuyerEmptySearchPage.routeName: BuyerEmptySearchPage.fromRoute,
          PublishBuyerNeedPage.routeName: (_) => const PublishBuyerNeedPage(),
          BuyerFavoritesPage.routeName: (_) => const BuyerFavoritesPage(),
        },
        home: const BuyerProductsPage(),
      ),
    );

    final search = find.byType(TextField).first;
    await tester.enterText(search, 'Tomate à Dakar');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.byType(BuyerEmptySearchPage), findsOneWidget);
    expect(find.text('Aucun produit trouvé'), findsOneWidget);
    expect(find.text('Publier une demande'), findsOneWidget);
    expect(find.text('Modifier les filtres'), findsOneWidget);
    expect(find.text('Créer une alerte de prix'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('l’état achats vide renvoie vers le marché', (tester) async {
    await usePhoneSize(tester);
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          BuyerProductsPage.routeName: (_) => const BuyerProductsPage(),
        },
        home: const BuyerPurchasesPage(
          arguments: BuyerPurchasesArguments(showEmptyState: true),
        ),
      ),
    );

    expect(find.text('Aucun achat pour le moment'), findsOneWidget);
    expect(find.text('Explorer le marché'), findsOneWidget);

    await tester.tap(find.text('Explorer le marché'));
    await tester.pumpAndSettle();

    expect(find.byType(BuyerProductsPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
