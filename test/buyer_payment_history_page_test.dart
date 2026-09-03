import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/features/buyer_payments/presentation/pages/buyer_payment_detail_page.dart';
import 'package:yokku_mbey/features/buyer_payments/presentation/pages/buyer_payment_history_page.dart';

void main() {
  testWidgets('filters payments and opens their detail', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        routes: {
          BuyerPaymentDetailPage.routeName: BuyerPaymentDetailPage.fromRoute,
        },
        home: BuyerPaymentHistoryPage(),
      ),
    );

    expect(find.text('Historique des paiements'), findsOneWidget);
    expect(find.text('Tomate fraîche'), findsOneWidget);
    expect(find.text('Oignon local'), findsOneWidget);
    expect(find.text('Pomme de terre'), findsOneWidget);

    await tester.tap(find.text('Réussis'));
    await tester.pump();
    expect(find.text('Tomate fraîche'), findsOneWidget);
    expect(find.text('Oignon local'), findsNothing);

    await tester.tap(find.text('Voir ›'));
    await tester.pumpAndSettle();
    expect(find.byType(BuyerPaymentDetailPage), findsOneWidget);
    expect(find.text('WAV-98A72KLM'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('downloads and shares a successful receipt', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: BuyerPaymentDetailPage(
          payment: BuyerPaymentRecord(
            reference: 'YK-2026-0184',
            transactionNumber: 'WAV-98A72KLM',
            productName: 'Tomate fraîche',
            producerName: 'Ibrahima Ndiaye',
            quantityKg: 200,
            amount: 80000,
            deposit: 0,
            fees: 0,
            method: 'Wave',
            dateLabel: "Aujourd'hui, 10:30",
            status: BuyerPaymentStatus.successful,
          ),
        ),
      ),
    );

    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, -700),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Télécharger le reçu'));
    await tester.pump();
    expect(find.text('Reçu téléchargé'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Partager'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
