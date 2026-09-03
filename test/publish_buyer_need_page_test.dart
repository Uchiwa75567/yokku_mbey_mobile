import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/features/buyer_needs/presentation/pages/publish_buyer_need_page.dart';
import 'package:yokku_mbey/features/home/presentation/pages/buyer_home_page.dart';

void main() {
  testWidgets('opens the buyer need form from the primary action', (
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
          PublishBuyerNeedPage.routeName: (_) => const PublishBuyerNeedPage(),
        },
        home: const BuyerHomePage(),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Action principale'));
    await tester.pumpAndSettle();

    expect(find.byType(PublishBuyerNeedPage), findsOneWidget);
    expect(find.text('Publier une demande'), findsOneWidget);
    expect(find.text('Produit recherché *'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('validates and publishes a buyer need', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(home: PublishBuyerNeedPage()),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ex. Tomate fraîche'),
      'Carotte locale',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, '1 000'),
      '500',
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Publier la demande'));
    await tester.pumpAndSettle();

    expect(find.text('Demande publiée'), findsOneWidget);
    expect(find.textContaining('Carotte locale'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
