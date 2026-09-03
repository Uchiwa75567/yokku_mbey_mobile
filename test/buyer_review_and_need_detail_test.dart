import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/features/buyer_needs/presentation/pages/buyer_need_detail_page.dart';
import 'package:yokku_mbey/features/buyer_needs/presentation/pages/buyer_proposals_page.dart';
import 'package:yokku_mbey/features/buyer_reviews/presentation/pages/buyer_rate_transaction_page.dart';

void main() {
  testWidgets('shows proposals from a buyer need', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        routes: {
          BuyerProposalsPage.routeName: BuyerProposalsPage.fromRoute,
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

    expect(find.text('Détail de la demande'), findsOneWidget);
    expect(find.text('4 propositions reçues'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Voir les\npropositions'),
      400,
    );
    await tester.tap(find.text('Voir les\npropositions'));
    await tester.pumpAndSettle();

    expect(find.byType(BuyerProposalsPage), findsOneWidget);
    expect(find.text('Ibrahima Ndiaye'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changes rating and publishes the review', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: BuyerRateTransactionPage(
          arguments: BuyerRateTransactionArguments(
            productName: 'Tomate fraîche',
            quantityKg: 200,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('4 étoiles'));
    await tester.pump();
    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Très bonne transaction.');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Publier mon avis'));
    await tester.pumpAndSettle();

    expect(find.text('Merci pour votre avis !'), findsOneWidget);
    expect(find.text('Votre note de 4/5 a été publiée.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
