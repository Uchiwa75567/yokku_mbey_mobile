import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/features/buyer_favorites/presentation/pages/buyer_create_alert_page.dart';
import 'package:yokku_mbey/features/buyer_favorites/presentation/pages/buyer_favorites_page.dart';
import 'package:yokku_mbey/features/buyer_needs/presentation/pages/buyer_need_detail_page.dart';
import 'package:yokku_mbey/features/buyer_needs/presentation/pages/publish_buyer_need_page.dart';
import 'package:yokku_mbey/features/buyer_products/presentation/pages/buyer_empty_search_page.dart';

void main() {
  Future<void> usePhoneSize(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('crée une alerte depuis une recherche vide', (tester) async {
    await usePhoneSize(tester);
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          BuyerCreateAlertPage.routeName: BuyerCreateAlertPage.fromRoute,
          BuyerFavoritesPage.routeName: (_) => const BuyerFavoritesPage(),
        },
        home: const BuyerEmptySearchPage(
          arguments: BuyerEmptySearchArguments(
            query: 'Tomate fraîche',
            location: 'Dakar',
          ),
        ),
      ),
    );

    await tester.tap(find.text('Créer une alerte de prix'));
    await tester.pumpAndSettle();

    expect(find.byType(BuyerCreateAlertPage), findsOneWidget);
    expect(find.text('Créer une alerte'), findsOneWidget);
    expect(find.text('Disponible maintenant'), findsOneWidget);

    await tester.drag(
      find.byType(CustomScrollView).last,
      const Offset(0, -700),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text("Créer l’alerte"));
    await tester.pumpAndSettle();

    expect(find.text('Alerte créée'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ouvre une demande préremplie en modification', (tester) async {
    await usePhoneSize(tester);
    await tester.pumpWidget(
      const MaterialApp(
        routes: {
          PublishBuyerNeedPage.routeName: PublishBuyerNeedPage.fromRoute,
        },
        home: BuyerNeedDetailPage(
          arguments: BuyerNeedDetailArguments(
            productName: 'Tomate fraîche',
            quantity: '1 000 kg',
            region: 'Dakar ou Thiès',
            proposals: 4,
          ),
        ),
      ),
    );

    await tester.dragUntilVisible(
      find.text('Modifier'),
      find.byType(CustomScrollView),
      const Offset(0, -350),
    );
    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();

    expect(find.text('Modifier la demande'), findsOneWidget);
    expect(find.text('Tomate fraîche'), findsWidgets);
    expect(find.text('Dakar ou Thiès'), findsWidgets);
    await tester.drag(
      find.byType(CustomScrollView).last,
      const Offset(0, -650),
    );
    await tester.pumpAndSettle();
    expect(find.text('Enregistrer les modifications'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
