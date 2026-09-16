import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/core/data/marketplace_models.dart';
import 'package:yokku_mbey/core/data/marketplace_store.dart';
import 'package:yokku_mbey/features/auth/presentation/pages/verification_page.dart';
import 'package:yokku_mbey/features/home/presentation/pages/profile_home_page.dart';
import 'package:yokku_mbey/features/profile_selection/domain/entities/profile_options.dart';
import 'package:yokku_mbey/features/profile_selection/domain/entities/user_profile_type.dart';
import 'package:yokku_mbey/features/profile_selection/presentation/pages/profile_selection_page.dart';
import 'support/marketplace_test_app.dart';

void authenticate(MarketplaceStore store, [String phone = '+221771234567']) {
  store.requestCode(phone);
  store.verifyCode('1234');
}

class ControlledPersistence extends MemoryWorkspacePersistence {
  bool fail = false;
  Completer<void>? pending;
  @override
  Future<void> write(String value) async {
    if (fail) throw StateError('Storage unavailable');
    if (pending != null) await pending!.future;
    await super.write(value);
  }
}

void main() {
  for (final role in UserProfileType.values) {
    test('${role.name} is remembered before any activity and after reload',
        () async {
      final persistence = MemoryWorkspacePersistence();
      final store = MarketplaceStore(persistence: persistence);
      authenticate(store);
      expect(store.role, isNull);
      await store.confirmRole(role);
      expect(store.role, role);
      store.signOut();
      expect(store.phone, isNull);
      authenticate(store);
      expect(store.role, role);
      final restored = MarketplaceStore(persistence: persistence);
      await restored.load();
      expect(restored.signedIn, isFalse);
      restored.requestCode('+221771234567');
      expect(
          () => restored.verifyCode('0000'), throwsA(isA<BusinessException>()));
      expect(restored.role, isNull);
      restored.verifyCode('1234');
      expect(restored.role, role);
    });
  }

  test('last workspace is per phone and account data stays isolated', () async {
    final store = MarketplaceStore(persistence: MemoryWorkspacePersistence());
    authenticate(store);
    await store.confirmRole(UserProfileType.buyer);
    await store.toggleFavorite('onion');
    final order = await store.reserve(
        productId: 'onion', quantity: 50, recovery: 'Retrait');
    await store.confirmRole(UserProfileType.investor);
    expect(store.record(order.id), isNull);
    expect(store.isFavorite('onion'), isFalse);
    await store.invest(
        projectId: 'irrigation', amount: 50000, message: '', consent: true);
    store.signOut();
    authenticate(store, '+221781234567');
    expect(store.role, isNull);
    await store.confirmRole(UserProfileType.provider);
    store.signOut();
    authenticate(store);
    expect(store.role, UserProfileType.investor);
    expect(store.records(RecordKind.investment), hasLength(1));
    await store.confirmRole(UserProfileType.buyer);
    expect(store.record(order.id), isNotNull);
    expect(store.isFavorite('onion'), isTrue);
    expect(store.records(RecordKind.investment), isEmpty);
    store.signOut();
    authenticate(store, '+221781234567');
    expect(store.role, UserProfileType.provider);
    expect(store.record(order.id), isNull);
  });

  test('legacy single role restores, ambiguous or invalid preferences do not',
      () async {
    final account = {'records': [], 'favorites': [], 'profile': {}};
    for (final entry in <(Map<String, dynamic>, UserProfileType?)>[
      (
        {
          'accounts': {'+221771234567:buyer': account}
        },
        UserProfileType.buyer
      ),
      (
        {
          'accounts': {
            '+221771234567:buyer': account,
            '+221771234567:farmer': account,
          }
        },
        null
      ),
      (
        {
          'accounts': {'+221771234567:buyer': account},
          'lastRoles': {'+221771234567': 'unknown'}
        },
        null
      ),
    ]) {
      final persistence = MemoryWorkspacePersistence()
        ..value = jsonEncode({'version': 1, 'sequence': 0, ...entry.$1});
      final store = MarketplaceStore(persistence: persistence);
      await store.load();
      expect(store.loadError, isNull);
      authenticate(store);
      expect(store.role, entry.$2);
    }
  });

  test('failed preference write preserves the previous role and can be retried',
      () async {
    final persistence = ControlledPersistence();
    final store = MarketplaceStore(persistence: persistence);
    authenticate(store);
    persistence.fail = true;
    await expectLater(store.confirmRole(UserProfileType.buyer),
        throwsA(isA<BusinessException>()));
    expect(store.role, isNull);
    persistence.fail = false;
    await store.confirmRole(UserProfileType.buyer);
    final saved = persistence.value;
    persistence.fail = true;
    await expectLater(store.confirmRole(UserProfileType.provider),
        throwsA(isA<BusinessException>()));
    expect(store.role, UserProfileType.buyer);
    expect(persistence.value, saved);
    persistence.fail = false;
    await store.confirmRole(UserProfileType.provider);
    store.signOut();
    authenticate(store);
    expect(store.role, UserProfileType.provider);
  });

  test('pending role writes block other saves and never reopen a session',
      () async {
    final persistence = ControlledPersistence();
    final store = MarketplaceStore(persistence: persistence);
    authenticate(store);
    await store.confirmRole(UserProfileType.buyer);
    persistence.pending = Completer<void>();
    final save = store.confirmRole(UserProfileType.investor);
    await expectLater(store.confirmRole(UserProfileType.provider),
        throwsA(isA<BusinessException>()));
    await expectLater(
        store.toggleFavorite('tomato'), throwsA(isA<BusinessException>()));
    store.signOut();
    authenticate(store, '+221781234567');
    final failure = expectLater(save, throwsA(isA<BusinessException>()));
    persistence.pending!.complete();
    await failure;
    expect(store.phone, '+221781234567');
    expect(store.role, isNull);
  });

  test('workspace change cannot overwrite an in-flight account save', () async {
    final persistence = ControlledPersistence();
    final store = MarketplaceStore(persistence: persistence);
    authenticate(store);
    await store.confirmRole(UserProfileType.buyer);
    persistence.pending = Completer<void>();
    final save = store.toggleFavorite('onion');
    await expectLater(store.confirmRole(UserProfileType.investor),
        throwsA(isA<BusinessException>()));
    persistence.pending!.complete();
    await save;
    expect(store.isFavorite('onion'), isTrue);
    expect(
        jsonDecode(persistence.value!)['lastRoles']['+221771234567'], 'buyer');
  });

  Future<void> tap(WidgetTester tester, String label) async {
    final target = find.text(label).last;
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  void viewport(WidgetTester tester, double width) {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  for (final width in [320.0, 390.0, 1440.0]) {
    testWidgets('confirmation is reversible and fits $width with large text',
        (tester) async {
      viewport(tester, width);
      final persistence = MemoryWorkspacePersistence();
      final store = MarketplaceStore(persistence: persistence);
      authenticate(store);
      await tester.pumpWidget(marketplaceTestApp(
          store: store, route: '/profile-selection', textScale: 1.5));
      await tap(tester, 'Acheteur');
      await tap(tester, 'Continuer');
      expect(find.text('Espace Acheteur'), findsOneWidget);
      expect(store.role, isNull);
      expect(persistence.value, isNull);
      await tap(tester, 'Modifier mon choix');
      expect(store.role, isNull);
      await tap(tester, 'Continuer');
      Navigator.of(tester.element(find.text('Modifier mon choix'))).pop();
      await tester.pumpAndSettle();
      expect(store.role, isNull);
      await tap(tester, 'Investisseur / ONG');
      await tap(tester, 'Continuer');
      expect(find.text('Espace Investisseur / ONG'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tap(tester, 'Entrer dans mon espace');
      expect(store.role, UserProfileType.investor);
      expect(find.byType(ProfileHomePage), findsOneWidget);
      expect(
          Navigator.of(tester.element(find.byType(ProfileHomePage))).canPop(),
          isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  for (final role in UserProfileType.values) {
    testWidgets('${role.name} can cancel and then change from their profile',
        (tester) async {
      viewport(tester, 390);
      final store = testStore(role);
      final next = role == UserProfileType.buyer
          ? UserProfileType.farmer
          : UserProfileType.buyer;
      await tester.pumpWidget(marketplaceTestApp(
          store: store,
          route: role == UserProfileType.farmer
              ? '/farmer-profile'
              : '/account-profile'));
      await tap(tester, 'Changer d’espace');
      expect(find.byType(ProfileSelectionPage), findsOneWidget);
      await tester.tap(find.byTooltip('Retour'));
      await tester.pumpAndSettle();
      expect(store.role, role);
      await tap(tester, 'Changer d’espace');
      await tap(
          tester, ProfileOptions.items.firstWhere((p) => p.type == next).title);
      await tap(tester, 'Continuer');
      expect(store.role, role);
      await tap(tester, 'Entrer dans mon espace');
      expect(store.role, next);
      expect(store.phone, '+221771234567');
      expect(
          Navigator.of(tester.element(find.byType(ProfileHomePage))).canPop(),
          isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('${role.name} returns directly home after OTP', (tester) async {
      viewport(tester, 390);
      final persistence = MemoryWorkspacePersistence();
      final previous = MarketplaceStore(persistence: persistence);
      authenticate(previous);
      await previous.confirmRole(role);
      previous.signOut();
      final store = MarketplaceStore(persistence: persistence);
      await store.load();
      store.requestCode('+221771234567');
      await tester
          .pumpWidget(marketplaceTestApp(store: store, route: '/verification'));
      for (final digit in ['1', '2', '3', '4']) {
        await tester.ensureVisible(find.text(digit));
        await tester.tap(find.text(digit));
        await tester.pump();
      }
      await tester.pump(VerificationPage.verificationSuccessDelay);
      await tester.pumpAndSettle();
      expect(find.byType(ProfileSelectionPage), findsNothing);
      expect(find.byType(ProfileHomePage), findsOneWidget);
      expect(store.role, role);
      expect(
          Navigator.of(tester.element(find.byType(ProfileHomePage))).canPop(),
          isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('preference failure stays on selection and offers retry',
      (tester) async {
    viewport(tester, 390);
    final persistence = ControlledPersistence()..fail = true;
    final store = MarketplaceStore(persistence: persistence);
    authenticate(store);
    await tester.pumpWidget(
        marketplaceTestApp(store: store, route: '/profile-selection'));
    await tap(tester, 'Acheteur');
    await tap(tester, 'Continuer');
    await tap(tester, 'Entrer dans mon espace');
    expect(store.role, isNull);
    expect(find.byType(ProfileSelectionPage), findsOneWidget);
    expect(find.textContaining('Votre choix n’a pas pu'), findsOneWidget);
    persistence.fail = false;
    await tap(tester, 'Continuer');
    await tap(tester, 'Entrer dans mon espace');
    expect(store.role, UserProfileType.buyer);
  });
}
