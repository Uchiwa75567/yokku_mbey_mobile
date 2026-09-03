import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/features/buyer_products/presentation/pages/buyer_product_detail_page.dart';

void main() {
  Future<void> expectEdgeToEdgeHero(
    WidgetTester tester,
    double width,
  ) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(
      const MaterialApp(home: BuyerProductDetailPage()),
    );
    await tester.pumpAndSettle();

    final hero = find.byKey(const ValueKey('product-detail-hero-image'));
    expect(hero, findsOneWidget);
    final rect = tester.getRect(hero);
    expect(rect.left, closeTo(0, 0.01));
    expect(rect.right, closeTo(width, 0.01));
    expect(rect.width, closeTo(width, 0.01));
    expect(tester.takeException(), isNull);
  }

  testWidgets('la photo occupe toute la largeur sur un téléphone standard', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    await expectEdgeToEdgeHero(tester, 390);
  });

  testWidgets('la photo reste bord à bord au-delà de 440 pixels logiques', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    await expectEdgeToEdgeHero(tester, 600);
  });
}
