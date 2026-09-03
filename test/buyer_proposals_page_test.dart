import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/features/buyer_needs/presentation/pages/buyer_proposal_detail_page.dart';
import 'package:yokku_mbey/features/buyer_needs/presentation/pages/buyer_proposals_page.dart';

void main() {
  testWidgets('sorts proposals and opens an offer', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        routes: {
          BuyerProposalDetailPage.routeName: BuyerProposalDetailPage.fromRoute,
        },
        home: BuyerProposalsPage(
          arguments: BuyerProposalsArguments(
            productName: 'Tomate fraîche',
            quantity: '1 000 kg',
          ),
        ),
      ),
    );

    expect(find.text('Propositions reçues'), findsOneWidget);
    expect(find.text('Ibrahima Ndiaye'), findsOneWidget);
    expect(find.text('Moussa Fall'), findsOneWidget);

    await tester.tap(find.text('Moins chères'));
    await tester.pump();
    final names = tester
        .widgetList<Text>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Text &&
                const {'Ibrahima Ndiaye', 'Moussa Fall', 'Aminata Ba'}
                    .contains(widget.data),
          ),
        )
        .map((text) => text.data)
        .toList();
    expect(names.first, 'Moussa Fall');

    await tester.tap(find.text("Voir l'offre").first);
    await tester.pumpAndSettle();
    expect(find.byType(BuyerProposalDetailPage), findsOneWidget);
    expect(find.text('410 FCFA/kg'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('accepts a proposal', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: BuyerProposalDetailPage(
          proposal: BuyerProposalData(
            producerName: 'Ibrahima Ndiaye',
            rating: 4.8,
            sales: 23,
            productName: 'Tomate fraîche',
            quantityKg: 1000,
            unitPrice: 425,
            availability: '15 au 20 juillet',
            location: 'Kaolack',
            recoveryMode: 'Retrait producteur',
            depositPercentage: 20,
            avatarColor: Color(0xFF087C2E),
            avatarBackground: Color(0xFFEDFCF3),
          ),
        ),
      ),
    );

    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, -850),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text("Accepter l'offre").first);
    await tester.pumpAndSettle();
    await tester.tap(find.text("Accepter l'offre").last);
    await tester.pumpAndSettle();

    expect(find.text('Offre acceptée avec succès'), findsOneWidget);
    expect(find.text('Répondu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
