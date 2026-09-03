import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/features/buyer_needs/presentation/pages/buyer_need_detail_page.dart';
import 'package:yokku_mbey/features/buyer_needs/presentation/pages/buyer_needs_page.dart';
import 'package:yokku_mbey/features/buyer_needs/presentation/pages/publish_buyer_need_page.dart';

void main() {
  testWidgets('shows buyer needs and opens their responses', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          PublishBuyerNeedPage.routeName: (_) => const PublishBuyerNeedPage(),
          BuyerNeedDetailPage.routeName: BuyerNeedDetailPage.fromRoute,
        },
        home: const BuyerNeedsPage(),
      ),
    );

    expect(find.text('Mes demandes'), findsOneWidget);
    expect(find.text('Tomate fraîche'), findsOneWidget);
    expect(find.text('Oignon local'), findsOneWidget);
    expect(find.text('Mangue Kent'), findsOneWidget);
    expect(find.text('4 propositions'), findsOneWidget);

    await tester.tap(find.text('Voir').first);
    await tester.pumpAndSettle();

    expect(find.byType(BuyerNeedDetailPage), findsOneWidget);
    expect(find.text('4 propositions reçues'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens a new need form', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          PublishBuyerNeedPage.routeName: (_) => const PublishBuyerNeedPage(),
        },
        home: const BuyerNeedsPage(),
      ),
    );

    await tester.tap(find.text('Nouvelle demande'));
    await tester.pumpAndSettle();

    expect(find.byType(PublishBuyerNeedPage), findsOneWidget);
  });
}
