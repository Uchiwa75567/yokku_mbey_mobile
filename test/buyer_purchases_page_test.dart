import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/features/buyer_purchases/presentation/pages/buyer_order_tracking_page.dart';
import 'package:yokku_mbey/features/buyer_purchases/presentation/pages/buyer_purchases_page.dart';
import 'package:yokku_mbey/features/home/presentation/pages/buyer_home_page.dart';

void main() {
  testWidgets('opens buyer purchases from the buyer navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          BuyerPurchasesPage.routeName: (_) => const BuyerPurchasesPage(),
          BuyerOrderTrackingPage.routeName: BuyerOrderTrackingPage.fromRoute,
        },
        home: const BuyerHomePage(),
      ),
    );

    await tester.tap(find.text('Achats'));
    await tester.pumpAndSettle();

    expect(find.byType(BuyerPurchasesPage), findsOneWidget);
    expect(find.text('Mes achats'), findsOneWidget);
    expect(find.text('Tomate fraîche'), findsOneWidget);
    expect(find.text('Oignon local'), findsOneWidget);
    expect(find.text('Pomme de terre'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filters and opens a completed purchase', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        routes: {
          BuyerOrderTrackingPage.routeName: BuyerOrderTrackingPage.fromRoute,
        },
        home: BuyerPurchasesPage(),
      ),
    );

    await tester.ensureVisible(find.text('Terminés'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terminés'));
    await tester.pump();

    expect(find.text('Pomme de terre'), findsOneWidget);
    expect(find.text('Tomate fraîche'), findsNothing);

    await tester.tap(find.text('Voir'));
    await tester.pumpAndSettle();

    expect(find.textContaining('75 000 FCFA'), findsWidgets);
    expect(find.textContaining('YM-8485'), findsWidgets);
    expect(find.text('Suivi de la commande'), findsOneWidget);
    expect(find.text('Transaction terminée'), findsOneWidget);

    await tester.drag(
      find.byType(CustomScrollView).last,
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    expect(find.text('Appeler ou WhatsApp'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
