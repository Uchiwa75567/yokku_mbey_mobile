import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/features/buyer_purchases/presentation/pages/buyer_order_tracking_page.dart';

void main() {
  testWidgets('la timeline est alignée sur un axe vertical continu', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: BuyerOrderTrackingPage(
          arguments: BuyerOrderTrackingArguments(
            productName: 'Tomate fraîche',
            quantityKg: 200,
            amount: 80000,
            completedSteps: 3,
          ),
        ),
      ),
    );

    final steps = List.generate(
      5,
      (index) => find.byKey(ValueKey('order-timeline-step-$index')),
    );
    for (final step in steps) {
      expect(step, findsOneWidget);
    }

    final first = tester.getTopLeft(steps.first);
    for (var index = 1; index < steps.length; index++) {
      final position = tester.getTopLeft(steps[index]);
      expect(position.dx, closeTo(first.dx, 0.01));
      expect(position.dy - first.dy, closeTo(70 * index, 0.01));
    }

    expect(
      find.byKey(const ValueKey('timeline-marker-completed')),
      findsNWidgets(3),
    );
    expect(
      find.byKey(const ValueKey('timeline-marker-pending')),
      findsNWidgets(2),
    );
    expect(find.text('Réservation envoyée'), findsOneWidget);
    expect(find.text("Acceptée par l'agriculteur"), findsOneWidget);
    expect(find.text('Produit en préparation'), findsOneWidget);
    expect(find.text('Prête pour récupération'), findsOneWidget);
    expect(find.text('Transaction terminée'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
