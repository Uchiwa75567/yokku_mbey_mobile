import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/features/buyer_notifications/presentation/pages/buyer_notifications_page.dart';
import 'package:yokku_mbey/features/buyer_support/presentation/pages/buyer_report_problem_page.dart';

void main() {
  Future<void> setPhoneSize(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('les notifications peuvent être filtrées', (tester) async {
    await setPhoneSize(tester);
    await tester.pumpWidget(
      const MaterialApp(home: BuyerNotificationsPage()),
    );

    expect(find.text('Proposition reçue'), findsOneWidget);
    expect(find.text('Réservation acceptée'), findsOneWidget);
    expect(find.text('Paiement confirmé'), findsOneWidget);

    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(-180, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Demandes'));
    await tester.pumpAndSettle();

    expect(find.text('Proposition reçue'), findsOneWidget);
    expect(find.text('Réservation acceptée'), findsNothing);
    expect(find.text('Paiement confirmé'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('le formulaire de signalement est interactif', (tester) async {
    await setPhoneSize(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: BuyerReportProblemPage(
          arguments: BuyerReportProblemArguments(
            reference: 'Commande YK-2026-0184',
          ),
        ),
      ),
    );

    expect(find.text('Produit non conforme'), findsOneWidget);
    await tester.tap(find.text('Quantité incorrecte'));
    await tester.enterText(
      find.byType(TextField),
      'La quantité reçue ne correspond pas à ma commande.',
    );
    await tester.dragUntilVisible(
      find.text('Ajouter des photos ou preuves'),
      find.byType(CustomScrollView),
      const Offset(0, -250),
    );
    await tester.tap(find.text('Ajouter des photos ou preuves'));
    await tester.pump();
    expect(find.text('1 preuve ajoutée'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Envoyer le signalement'),
      find.byType(CustomScrollView),
      const Offset(0, -250),
    );
    await tester.tap(find.text('Envoyer le signalement'));
    await tester.pumpAndSettle();

    expect(find.text('Signalement envoyé'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
