import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/app/yokku_mbey_app.dart';
import 'package:yokku_mbey/core/data/marketplace_models.dart';
import 'package:yokku_mbey/core/data/marketplace_store.dart';
import 'package:yokku_mbey/features/auth/presentation/pages/login_page.dart';
import 'package:yokku_mbey/features/auth/presentation/pages/verification_page.dart';
import 'package:yokku_mbey/features/profile_selection/domain/entities/user_profile_type.dart';
import 'package:yokku_mbey/features/profile_selection/presentation/pages/profile_selection_page.dart';
import 'package:yokku_mbey/features/splash/presentation/pages/splash_page.dart';
import 'support/marketplace_test_app.dart';

void main() {
  Finder quantityButton(String label) => find.byWidgetPredicate(
      (widget) => widget is IconButton && widget.tooltip == label);
  Future<void> tap(WidgetTester tester, String text) async {
    final finder = find.text(text).last;
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    if (find.byType(AlertDialog).evaluate().isEmpty) {
      await tester.pumpAndSettle();
    }
  }

  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets(
      'buyer reserves the selected product, sees it in purchases and cancels',
      (tester) async {
    phone(tester);
    final store = testStore(UserProfileType.buyer);
    await tester.pumpWidget(marketplaceTestApp(store: store));
    await tap(tester, 'Marché');
    await tester.enterText(find.byType(TextField).first, 'oignon');
    await tester.pumpAndSettle();
    expect(find.text('Tomate fraîche'), findsNothing);
    await tap(tester, 'Oignon local');
    await tester.enterText(find.byType(TextFormField).first, '100');
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tap(tester, 'Demander une réservation');
    expect(find.text('Réservation enregistrée'), findsOneWidget);
    expect(store.records(RecordKind.order).single.amount, 35000);
    await tap(tester, 'Voir mes achats');
    await tap(tester, 'Oignon local');
    await tap(tester, 'Annuler la réservation');
    await tap(tester, 'Confirmer');
    expect(
        store.records(RecordKind.order).single.status, RecordStatus.cancelled);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reservation stepper respects bounds and recalculates total',
      (tester) async {
    phone(tester);
    final store = testStore(UserProfileType.buyer);
    final product = MarketplaceCatalog.product('tomato');
    await tester.pumpWidget(marketplaceTestApp(
        store: store, route: '/buyer-product-detail', arguments: product.id));
    final field = find.byType(TextFormField).first;
    final minus = quantityButton('Diminuer la quantité');
    final plus = quantityButton('Augmenter la quantité');
    await tester.ensureVisible(plus);
    expect(tester.widget<IconButton>(minus).onPressed, isNull);
    await tester.tap(plus);
    await tester.pump();
    expect(tester.widget<TextFormField>(field).controller!.text,
        '${product.minimum * 2}');
    expect(find.text(formatCfa(product.minimum * 2 * product.unitPrice)),
        findsOneWidget);
    await tester.enterText(field, '${product.stock - 1}');
    await tester.pump();
    await tester.ensureVisible(plus);
    await tester.tap(plus);
    await tester.pump();
    expect(tester.widget<TextFormField>(field).controller!.text,
        '${product.stock}');
    expect(tester.widget<IconButton>(plus).onPressed, isNull);
    await tester.enterText(field, '0');
    await tester.pump();
    await tester.ensureVisible(plus);
    await tester.tap(plus);
    await tester.pump();
    expect(tester.widget<TextFormField>(field).controller!.text,
        '${product.minimum}');
    expect(tester.takeException(), isNull);
  });

  testWidgets('insufficient remaining stock disables both quantity buttons',
      (tester) async {
    phone(tester);
    final store = testStore(UserProfileType.buyer);
    final product = MarketplaceCatalog.product('tomato');
    await store.reserve(
        productId: product.id,
        quantity: product.stock - 1,
        recovery: 'Retrait');
    await tester.pumpWidget(marketplaceTestApp(
        store: store, route: '/buyer-product-detail', arguments: product.id));
    await tester.enterText(find.byType(TextFormField).first, '0');
    await tester.pump();
    expect(
        tester
            .widget<IconButton>(quantityButton('Diminuer la quantité'))
            .onPressed,
        isNull);
    expect(
        tester
            .widget<IconButton>(quantityButton('Augmenter la quantité'))
            .onPressed,
        isNull);
    final submit =
        find.widgetWithText(FilledButton, 'Demander une réservation');
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);
    expect(store.records(RecordKind.order), hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('buyer publishes then edits the same need', (tester) async {
    phone(tester);
    final store = testStore(UserProfileType.buyer);
    await tester.pumpWidget(
        marketplaceTestApp(store: store, route: '/publish-buyer-need'));
    await tester.enterText(find.byType(TextFormField).at(0), 'Tomate');
    await tester.enterText(find.byType(TextFormField).at(1), '200');
    await tester.enterText(find.byType(TextFormField).at(2), '90000');
    await tap(tester, 'Publier ma demande');
    expect(store.records(RecordKind.need), hasLength(1));
    await tap(tester, 'Tomate');
    await tap(tester, 'Modifier ma demande');
    await tester.enterText(find.byType(TextFormField).at(1), '250');
    await tap(tester, 'Enregistrer les modifications');
    expect(store.records(RecordKind.need).single.quantity, 250);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'investor opens a project and records an intention without changing funds raised',
      (tester) async {
    phone(tester);
    final store = testStore(UserProfileType.investor);
    await tester.pumpWidget(marketplaceTestApp(store: store));
    await tap(tester, 'Voir les projets');
    await tap(tester, 'Irrigation des Niayes');
    await tap(tester, 'Soutenir ce projet');
    await tester.enterText(find.byType(TextFormField).first, '100000');
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tap(tester, 'Enregistrer mon intention');
    expect(store.records(RecordKind.investment).single.amount, 100000);
    expect(find.text('En attente'), findsOneWidget);
    expect(MarketplaceCatalog.project('irrigation').raised, 1800000);
    await tap(tester, 'Retirer mon intention');
    await tap(tester, 'Confirmer');
    expect(store.records(RecordKind.investment).single.status,
        RecordStatus.cancelled);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'provider publishes a service then creates a quote linked to that service',
      (tester) async {
    phone(tester);
    final store = testStore(UserProfileType.provider);
    await tester.pumpWidget(marketplaceTestApp(store: store));
    await tap(tester, 'Ajouter un service');
    await tester.enterText(
        find.byType(TextFormField).at(0), 'Transport de récoltes');
    await tester.enterText(find.byType(TextFormField).at(1), '75000');
    await tester.enterText(find.byType(TextFormField).at(2),
        'Camion avec conducteur et carburant');
    await tap(tester, 'Publier le service');
    expect(store.records(RecordKind.service), hasLength(1));
    await tap(tester, 'Accueil');
    await tap(tester, 'Voir les demandes');
    await tap(tester, 'Transport de 2 tonnes d’oignons');
    await tap(tester, 'Proposer un devis');
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tap(tester, 'Transport de récoltes');
    await tester.enterText(find.byType(TextFormField).at(0), '80000');
    await tester.enterText(
        find.byType(TextFormField).at(1), 'Chargement et transport inclus');
    await tap(tester, 'Enregistrer le devis');
    expect(store.records(RecordKind.job).single.amount, 80000);
    expect(store.records(RecordKind.job).single.attributes['serviceId'],
        store.records(RecordKind.service).single.id);
    expect(find.text('Démarrer la mission'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final role in UserProfileType.values) {
    testWidgets('${role.name} logout clears session and back stack',
        (tester) async {
      phone(tester);
      final store = testStore(role);
      await tester.pumpWidget(marketplaceTestApp(
          store: store,
          route: role == UserProfileType.farmer
              ? '/farmer-profile'
              : role == UserProfileType.buyer
                  ? '/buyer-profile'
                  : '/account-profile'));
      await tap(tester, 'Se déconnecter');
      await tap(tester, 'Se déconnecter');
      expect(store.signedIn, isFalse);
      expect(find.byType(LoginPage), findsOneWidget);
      expect(Navigator.of(tester.element(find.byType(LoginPage))).canPop(),
          isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'real app rejects protected routes while signed out and validates OTP',
      (tester) async {
    phone(tester);
    final store = MarketplaceStore(persistence: MemoryWorkspacePersistence());
    await tester.pumpWidget(YokkuMbeyApp(store: store));
    Navigator.of(tester.element(find.byType(SplashPage)))
        .pushNamedAndRemoveUntil('/provider-services', (_) => false);
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '77 123 45 67');
    await tap(tester, 'Continuer');
    for (final digit in ['0', '0', '0', '0']) {
      await tester.tap(find.text(digit).last);
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.byType(VerificationPage), findsOneWidget);
    expect(store.phone, isNull);
    for (final digit in ['1', '2', '3', '4']) {
      await tester.tap(find.text(digit).last);
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSelectionPage), findsOneWidget);
    await tap(tester, 'Acheteur');
    await tap(tester, 'Continuer');
    expect(store.role, isNull);
    await tap(tester, 'Entrer dans mon espace');
    expect(store.role, UserProfileType.buyer);
    expect(find.text('Produits disponibles'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
