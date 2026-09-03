import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/features/buyer_products/presentation/pages/buyer_payment_page.dart';
import 'package:yokku_mbey/features/buyer_products/presentation/pages/buyer_reservation_confirmation_page.dart';
import 'package:yokku_mbey/features/buyer_purchases/presentation/pages/buyer_order_tracking_page.dart';

void main() {
  testWidgets('confirme le paiement et ouvre le suivi de réservation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        routes: {
          BuyerReservationConfirmationPage.routeName:
              BuyerReservationConfirmationPage.fromRoute,
          BuyerOrderTrackingPage.routeName: BuyerOrderTrackingPage.fromRoute,
        },
        home: BuyerPaymentPage(),
      ),
    );

    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Payer 80 000 FCFA'));
    await tester.pumpAndSettle();

    expect(find.byType(BuyerReservationConfirmationPage), findsOneWidget);
    expect(find.text('Réservation confirmée !'), findsOneWidget);
    expect(find.text('En attente du producteur'), findsOneWidget);
    expect(find.text('YK-2026-0184'), findsOneWidget);

    await tester.ensureVisible(find.text('Voir ma réservation'));
    await tester.tap(find.text('Voir ma réservation'));
    await tester.pumpAndSettle();

    expect(find.byType(BuyerOrderTrackingPage), findsOneWidget);
    expect(find.text('Suivi de la commande'), findsOneWidget);
    expect(find.text('YK-2026-0184'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
