import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/app/app_routes.dart';
import 'package:yokku_mbey/features/buyer_favorites/presentation/pages/buyer_alert_detail_page.dart';
import 'package:yokku_mbey/features/buyer_favorites/presentation/pages/buyer_create_alert_page.dart';
import 'package:yokku_mbey/features/buyer_needs/presentation/pages/buyer_proposal_checkout_pages.dart';
import 'package:yokku_mbey/features/buyer_needs/presentation/pages/buyer_proposal_detail_page.dart';
import 'package:yokku_mbey/features/buyer_payments/presentation/pages/buyer_saved_payment_methods_page.dart';
import 'package:yokku_mbey/features/buyer_profile/presentation/pages/buyer_account_pages.dart';
import 'package:yokku_mbey/features/buyer_support/presentation/pages/buyer_issue_detail_page.dart';

void main() {
  Future<void> phone(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('les pages spécifiques du compte acheteur sont routées', (
    tester,
  ) async {
    await phone(tester);
    for (final route in [
      BuyerPersonalInfoPage.routeName,
      BuyerSettingsPage.routeName,
      BuyerHelpSupportPage.routeName,
      BuyerReputationPage.routeName,
      BuyerSavedPaymentMethodsPage.routeName,
    ]) {
      await tester.pumpWidget(
        MaterialApp(initialRoute: route, routes: AppRoutes.routes),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsWidgets);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('le détail d’alerte ouvre son formulaire prérempli', (
    tester,
  ) async {
    await phone(tester);
    await tester.pumpWidget(
      const MaterialApp(
        routes: {
          BuyerCreateAlertPage.routeName: BuyerCreateAlertPage.fromRoute,
        },
        home: BuyerAlertDetailPage(),
      ),
    );
    await tester.tap(find.text('Modifier l’alerte'));
    await tester.pumpAndSettle();
    expect(find.text('Modifier l’alerte'), findsOneWidget);
    expect(find.text('Enregistrer les modifications'), findsOneWidget);
  });

  testWidgets('le signalement possède un écran de suivi', (tester) async {
    await phone(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: BuyerIssueDetailPage(
          arguments: BuyerIssueDetailArguments(),
        ),
      ),
    );
    expect(find.text('Suivi du signalement'), findsOneWidget);
    expect(find.text('En cours d’examen'), findsOneWidget);
    expect(find.text('Réponse et résolution'), findsOneWidget);
  });

  testWidgets('une proposition acceptée mène au paiement de l’acompte', (
    tester,
  ) async {
    await phone(tester);
    const proposal = BuyerProposalData(
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
    );
    await tester.pumpWidget(
      const MaterialApp(
        routes: {
          BuyerProposalPaymentPage.routeName:
              BuyerProposalPaymentPage.fromRoute,
        },
        home: BuyerProposalAcceptedPage(proposal: proposal),
      ),
    );
    await tester.tap(find.text('Payer l’acompte'));
    await tester.pumpAndSettle();
    expect(find.byType(BuyerProposalPaymentPage), findsOneWidget);
    expect(find.text('Payer 85 000 FCFA'), findsOneWidget);
  });

  testWidgets('les moyens de paiement peuvent être ajoutés', (tester) async {
    await phone(tester);
    await tester.pumpWidget(
      const MaterialApp(home: BuyerSavedPaymentMethodsPage()),
    );
    expect(find.text('Wave'), findsOneWidget);
    await tester.tap(find.text('Ajouter un moyen de paiement'));
    await tester.pump();
    expect(find.text('Nouvelle carte'), findsOneWidget);
  });
}
