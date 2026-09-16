import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/core/data/marketplace_models.dart';
import 'package:yokku_mbey/core/data/marketplace_store.dart';
import 'package:yokku_mbey/features/profile_selection/domain/entities/user_profile_type.dart';

void signIn(MarketplaceStore store, UserProfileType role,
    {String phone = '+221771234567'}) {
  store.requestCode(phone);
  store.verifyCode('1234');
  store.selectRole(role);
}

void main() {
  late MemoryWorkspacePersistence persistence;
  late MarketplaceStore store;
  setUp(() {
    persistence = MemoryWorkspacePersistence();
    store = MarketplaceStore(persistence: persistence);
  });

  test(
      'stock is shared across local buyer accounts without exposing their orders',
      () async {
    signIn(store, UserProfileType.buyer);
    await store.reserve(
        productId: 'tomato', quantity: 450, recovery: 'Retrait');
    store.signOut();
    signIn(store, UserProfileType.buyer, phone: '+221781234567');
    expect(store.records(RecordKind.order), isEmpty);
    expect(store.remainingStock(MarketplaceCatalog.product('tomato')), 50);
    await expectLater(
        store.reserve(productId: 'tomato', quantity: 100, recovery: 'Retrait'),
        throwsA(isA<BusinessException>()));
  });

  test('invalid saved data is reported and never overwritten', () async {
    persistence.value = '{invalid';
    await store.load();
    expect(store.loadError, isNotNull);
    signIn(store, UserProfileType.buyer);
    await expectLater(
        store.toggleFavorite('tomato'), throwsA(isA<BusinessException>()));
    expect(persistence.value, '{invalid');
  });

  test(
      'OTP rejects invalid numbers, wrong codes, expired codes and rapid resends',
      () {
    var now = DateTime(2026, 9, 13);
    final auth = MarketplaceStore(persistence: persistence, clock: () => now);
    expect(() => auth.requestCode('+22112'), throwsA(isA<BusinessException>()));
    auth.requestCode('+221771234567');
    expect(() => auth.requestCode('+221771234567'),
        throwsA(isA<BusinessException>()));
    expect(() => auth.verifyCode('0000'), throwsA(isA<BusinessException>()));
    expect(auth.phone, isNull);
    now = now.add(const Duration(minutes: 6));
    expect(() => auth.verifyCode('1234'), throwsA(isA<BusinessException>()));
    auth.requestCode('+221771234567');
    auth.verifyCode('1234');
    auth.selectRole(UserProfileType.buyer);
    expect(auth.signedIn, isTrue);
    auth.signOut();
    expect(() => auth.selectRole(UserProfileType.investor),
        throwsA(isA<BusinessException>()));
  });

  test(
      'reservation validates quantity and computes total, cancellation releases stock',
      () async {
    signIn(store, UserProfileType.buyer);
    await expectLater(
        store.reserve(productId: 'tomato', quantity: 49, recovery: 'Retrait'),
        throwsA(isA<BusinessException>()));
    await expectLater(
        store.reserve(productId: 'tomato', quantity: 501, recovery: 'Retrait'),
        throwsA(isA<BusinessException>()));
    final order = await store.reserve(
        productId: 'tomato', quantity: 200, recovery: 'Retrait');
    expect(order.amount, 80000);
    expect(order.status, RecordStatus.pending);
    expect(store.remainingStock(MarketplaceCatalog.product('tomato')), 300);
    await expectLater(
        store.reserve(productId: 'tomato', quantity: 350, recovery: 'Retrait'),
        throwsA(isA<BusinessException>()));
    await expectLater(store.transition(order.id, RecordStatus.completed),
        throwsA(isA<BusinessException>()));
    await store.transition(order.id, RecordStatus.cancelled);
    expect(store.remainingStock(MarketplaceCatalog.product('tomato')), 500);
    await expectLater(store.transition(order.id, RecordStatus.active),
        throwsA(isA<BusinessException>()));
  });

  test('delivery requires a saved address and stores its immutable snapshot',
      () async {
    signIn(store, UserProfileType.buyer);
    await expectLater(
        store.reserve(productId: 'onion', quantity: 50, recovery: 'Livraison'),
        throwsA(isA<BusinessException>()));
    await store.saveAddress(name: 'Marché', region: 'Dakar', details: 'Rue 12');
    final address = store.records(RecordKind.address).single;
    final order = await store.reserve(
        productId: 'onion',
        quantity: 50,
        recovery: 'Livraison',
        addressId: address.id);
    await store.removeAddress(address.id);
    expect(store.record(order.id)!.attributes['address'], contains('Rue 12'));
  });

  test('data survives reload and is isolated by phone and role', () async {
    signIn(store, UserProfileType.buyer);
    await store.toggleFavorite('onion');
    await store.reserve(productId: 'onion', quantity: 50, recovery: 'Retrait');
    store.signOut();
    expect(store.records(RecordKind.order), isEmpty);
    final loaded = MarketplaceStore(persistence: persistence);
    await loaded.load();
    expect(loaded.signedIn, isFalse);
    signIn(loaded, UserProfileType.buyer);
    expect(loaded.records(RecordKind.order), hasLength(1));
    expect(loaded.isFavorite('onion'), isTrue);
    loaded.selectRole(UserProfileType.investor);
    expect(loaded.records(RecordKind.order), isEmpty);
    expect(loaded.isFavorite('onion'), isFalse);
    await expectLater(
        loaded.reserve(productId: 'onion', quantity: 50, recovery: 'Retrait'),
        throwsA(isA<BusinessException>()));
    loaded.signOut();
    signIn(loaded, UserProfileType.buyer, phone: '+221781234567');
    expect(loaded.records(RecordKind.order), isEmpty);
  });

  test('needs can be updated by ID then closed without duplicates', () async {
    signIn(store, UserProfileType.buyer);
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    await store.saveNeed(
        title: 'Tomate',
        quantity: 100,
        unit: 'kg',
        region: 'Kaolack',
        budget: 50000,
        date: tomorrow,
        details: '');
    final need = store.records(RecordKind.need).single;
    await store.saveNeed(
        id: need.id,
        title: 'Tomate',
        quantity: 200,
        unit: 'kg',
        region: 'Kaolack',
        budget: 90000,
        date: tomorrow,
        details: 'Pour le marché');
    expect(store.records(RecordKind.need).single.quantity, 200);
    await store.transition(need.id, RecordStatus.closed);
    await expectLater(
        store.saveNeed(
            id: need.id,
            title: 'Tomate',
            quantity: 300,
            unit: 'kg',
            region: 'Kaolack',
            budget: 100000,
            date: tomorrow,
            details: ''),
        throwsA(isA<BusinessException>()));
  });

  test('funding enforces consent, min/max and one open intention per project',
      () async {
    signIn(store, UserProfileType.investor);
    await expectLater(
        store.invest(
            projectId: 'irrigation', amount: 100, message: '', consent: true),
        throwsA(isA<BusinessException>()));
    await expectLater(
        store.invest(
            projectId: 'irrigation',
            amount: 50000,
            message: '',
            consent: false),
        throwsA(isA<BusinessException>()));
    await expectLater(
        store.invest(
            projectId: 'irrigation',
            amount: 2000000,
            message: '',
            consent: true),
        throwsA(isA<BusinessException>()));
    final result = await store.invest(
        projectId: 'irrigation', amount: 100000, message: '', consent: true);
    expect(result.status, RecordStatus.pending);
    expect(MarketplaceCatalog.project('irrigation').raised, 1800000);
    await expectLater(
        store.invest(
            projectId: 'irrigation', amount: 50000, message: '', consent: true),
        throwsA(isA<BusinessException>()));
    await store.transition(result.id, RecordStatus.cancelled);
    await store.invest(
        projectId: 'irrigation', amount: 50000, message: '', consent: true);
    expect(store.records(RecordKind.investment), hasLength(2));
  });

  test(
      'provider quotes require active compatible service and cannot self-approve',
      () async {
    signIn(store, UserProfileType.provider);
    await store.saveService(
        title: 'Transport',
        category: 'Transport',
        region: 'Thiès',
        price: 75000,
        unit: 'trajet',
        details: 'Avec conducteur');
    final service = store.records(RecordKind.service).single;
    final date = DateTime.now().add(const Duration(days: 2));
    await expectLater(
        store.quote(
            requestId: 'tractor',
            serviceId: service.id,
            amount: 80000,
            date: date,
            details: 'Inclus'),
        throwsA(isA<BusinessException>()));
    await store.transition(service.id, RecordStatus.paused);
    await expectLater(
        store.quote(
            requestId: 'transport',
            serviceId: service.id,
            amount: 80000,
            date: date,
            details: 'Inclus'),
        throwsA(isA<BusinessException>()));
    await store.transition(service.id, RecordStatus.active);
    final quote = await store.quote(
        requestId: 'transport',
        serviceId: service.id,
        amount: 80000,
        date: date,
        details: 'Carburant inclus');
    await expectLater(store.transition(quote.id, RecordStatus.accepted),
        throwsA(isA<BusinessException>()));
    await expectLater(store.transition(quote.id, RecordStatus.completed),
        throwsA(isA<BusinessException>()));
    await expectLater(
        store.quote(
            requestId: 'transport',
            serviceId: service.id,
            amount: 80000,
            date: date,
            details: 'Autre'),
        throwsA(isA<BusinessException>()));
    await store.transition(quote.id, RecordStatus.cancelled);
    expect(store.record(quote.id)!.status, RecordStatus.cancelled);
  });

  test('failed persistence leaves the UI state unchanged', () async {
    final failing = MarketplaceStore(persistence: _FailingPersistence());
    signIn(failing, UserProfileType.buyer);
    await expectLater(
        failing.reserve(productId: 'tomato', quantity: 50, recovery: 'Retrait'),
        throwsA(isA<BusinessException>()));
    expect(failing.records(RecordKind.order), isEmpty);
    expect(failing.remainingStock(MarketplaceCatalog.product('tomato')), 500);
  });

  test('logout during persistence never restores the previous account',
      () async {
    final delayed = _DelayedPersistence();
    final s = MarketplaceStore(persistence: delayed);
    signIn(s, UserProfileType.buyer);
    final save = s.toggleFavorite('tomato');
    s.signOut();
    delayed.completer.complete();
    await save;
    expect(s.signedIn, isFalse);
    expect(s.isFavorite('tomato'), isFalse);
  });
}

class _FailingPersistence implements WorkspacePersistence {
  @override
  Future<String?> read() async => null;
  @override
  Future<void> write(String value) async => throw Exception('disk unavailable');
}

class _DelayedPersistence implements WorkspacePersistence {
  final completer = Completer<void>();
  @override
  Future<String?> read() async => null;
  @override
  Future<void> write(String value) => completer.future;
}
