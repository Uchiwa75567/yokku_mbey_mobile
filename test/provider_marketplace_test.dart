import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:yokku_mbey/core/data/marketplace_models.dart';
import 'package:yokku_mbey/core/data/marketplace_store.dart';
import 'package:yokku_mbey/core/data/service_photos.dart';
import 'package:yokku_mbey/features/profile_selection/domain/entities/user_profile_type.dart';

void login(MarketplaceStore store, UserProfileType role,
    {String phone = '+221771234567'}) {
  store.signOut();
  store.requestCode(phone);
  store.verifyCode('1234');
  store.selectRole(role);
}

String photoFixture() => prepareServicePhoto(
    Uint8List.fromList(img.encodePng(img.Image(width: 4, height: 3))));

Future<String> publish(MarketplaceStore store,
    {bool worker = false, DateTime? available}) async {
  await store.saveService(
      title: worker ? 'Ouvrier agricole' : 'Tracteur et conducteur',
      category: worker ? 'Récolte' : 'Tracteur',
      region: 'Thiès',
      price: worker ? 5000 : 40000,
      unit: worker ? 'jour' : 'hectare',
      details: 'Travail et déplacement inclus.',
      serviceType: worker ? ServiceType.workforce : ServiceType.technical,
      experience: worker ? 'Trois campagnes de récolte' : '',
      photos: worker ? [] : [photoFixture()],
      availableFrom: available);
  return store.records(RecordKind.service).first.id;
}

void main() {
  late MemoryWorkspacePersistence persistence;
  late MarketplaceStore store;
  final day = DateTime(2026, 9, 15);
  setUp(() {
    persistence = MemoryWorkspacePersistence();
    store = MarketplaceStore(persistence: persistence, clock: () => day);
    login(store, UserProfileType.provider);
  });
  final businessError = throwsA(isA<BusinessException>());

  test(
      'normalization yields JPEG without upscaling and persists backwards compatibly',
      () {
    final photo = photoFixture();
    validateServicePhotos([photo]);
    final decoded = img.decodeJpg(servicePhotoBytes(photo))!;
    expect(decoded.width, 4);
    expect(decoded.height, 3);
    final record = MarketRecord(
        id: 's',
        kind: RecordKind.service,
        title: 'T',
        createdAt: day,
        photos: [photo]);
    expect(MarketRecord.fromJson(record.toJson()).photos, [photo]);
    expect(record.withStatus(RecordStatus.paused).photos, [photo]);
    final legacy = record.toJson()..remove('photos');
    expect(MarketRecord.fromJson(legacy).photos, isEmpty);
    expect(() => record.photos.add(photo), throwsUnsupportedError);
  });

  test('normalization reduces large dimensions and rejects unreadable input',
      () {
    final input =
        Uint8List.fromList(img.encodePng(img.Image(width: 1200, height: 600)));
    final result = prepareServicePhoto(input);
    final decoded = img.decodeJpg(servicePhotoBytes(result))!;
    expect(decoded.width, 960);
    expect(decoded.height, 480);
    expect(() => prepareServicePhoto(Uint8List.fromList([1, 2, 3])),
        throwsFormatException);
    expect(() => validateServicePhotos(List.filled(4, photoFixture())),
        throwsFormatException);
    expect(
        () => validateServicePhotos(['assets/images/service_tractor_demo.png']),
        throwsFormatException);
    expect(() => validateServicePhotos(['data:image/jpeg;base64,YWJj']),
        throwsFormatException);
  });

  test(
      'equipment needs a real photo, worker requires skills and compatible units',
      () async {
    for (final category in ['Tracteur', 'Matériel']) {
      await expectLater(
          store.saveService(
              title: 'Location',
              category: category,
              region: 'Thiès',
              price: 10000,
              unit: 'jour',
              details: 'Avec conducteur'),
          businessError);
    }
    await expectLater(
        store.saveService(
            title: 'Récolte',
            category: 'Récolte',
            region: 'Thiès',
            price: 5000,
            unit: 'jour',
            details: 'Travail au champ',
            serviceType: ServiceType.workforce),
        businessError);
    await expectLater(
        store.saveService(
            title: 'Récolte',
            category: 'Récolte',
            region: 'Thiès',
            price: 5000,
            unit: 'trajet',
            details: 'Travail au champ',
            serviceType: ServiceType.workforce,
            experience: '3 saisons'),
        businessError);
    await publish(store, worker: true);
    expect(store.records(RecordKind.service).single.serviceType,
        ServiceType.workforce);
    expect(store.records(RecordKind.service).single.photos, isEmpty);
  });

  test(
      'published photos survive reload, while private provider records stay private',
      () async {
    final id = await publish(store);
    await store.saveProfile({'name': 'Mamadou', 'organization': 'Entreprise'});
    final loaded = MarketplaceStore(persistence: persistence, clock: () => day);
    await loaded.load();
    login(loaded, UserProfileType.farmer, phone: '+221781234567');
    final offer = loaded.publishedService(id)!;
    expect(offer.record.photos, [photoFixture()]);
    expect(offer.providerName, 'Mamadou');
    expect(loaded.record(id), isNull);
    expect(loaded.records(RecordKind.service), isEmpty);
    login(loaded, UserProfileType.buyer);
    expect(loaded.publishedServices(), isEmpty);
  });

  test('pausing hides an offer; reactivation restores its photos', () async {
    final id = await publish(store);
    await store.transition(id, RecordStatus.paused);
    login(store, UserProfileType.farmer);
    expect(store.publishedService(id), isNull);
    await expectLater(
        store.requestService(
            serviceId: id,
            quantity: 1,
            date: day,
            details: 'Labour de mon champ'),
        businessError);
    login(store, UserProfileType.provider);
    await store.transition(id, RecordStatus.active);
    login(store, UserProfileType.farmer);
    expect(store.publishedService(id)!.record.photos, hasLength(1));
  });

  test('requests share immutable price and status with both participants only',
      () async {
    final id = await publish(store);
    login(store, UserProfileType.farmer, phone: '+221781234567');
    final request = await store.requestService(
        serviceId: id,
        quantity: 3,
        date: day,
        details: 'Labour de trois hectares à Thiès');
    expect(request.amount, 120000);
    expect(request.status, RecordStatus.pending);
    await expectLater(
        store.transition(request.id, RecordStatus.accepted), businessError);
    await expectLater(
        store.requestService(
            serviceId: id,
            quantity: 2,
            date: day,
            details: 'Labour de mon champ'),
        businessError);

    login(store, UserProfileType.provider, phone: '+221761234567');
    expect(store.record(request.id), isNull);
    await expectLater(
        store.transition(request.id, RecordStatus.accepted), businessError);
    login(store, UserProfileType.provider);
    expect(store.record(request.id)!.amount, 120000);
    await expectLater(
        store.transition(request.id, RecordStatus.completed), businessError);
    await store.transition(request.id, RecordStatus.accepted);
    await store.saveService(
        id: id,
        title: 'Tracteur',
        category: 'Tracteur',
        region: 'Thiès',
        price: 50000,
        unit: 'hectare',
        details: 'Conducteur inclus',
        photos: [photoFixture()]);
    expect(store.record(request.id)!.amount, 120000);
    await store.transition(request.id, RecordStatus.active);
    await store.transition(request.id, RecordStatus.completed);
    login(store, UserProfileType.farmer, phone: '+221781234567');
    expect(store.record(request.id)!.status, RecordStatus.completed);
    await expectLater(
        store.transition(request.id, RecordStatus.cancelled), businessError);
  });

  test('worker request can be declined or cancelled, then requested again',
      () async {
    final id = await publish(store, worker: true);
    login(store, UserProfileType.farmer);
    final first = await store.requestService(
        serviceId: id,
        quantity: 2,
        date: day,
        details: 'Récolte de légumes au champ');
    expect(first.amount, 10000);
    await store.transition(first.id, RecordStatus.cancelled);
    login(store, UserProfileType.provider);
    expect(store.record(first.id)!.status, RecordStatus.cancelled);
    await expectLater(
        store.transition(first.id, RecordStatus.accepted), businessError);
    login(store, UserProfileType.farmer);
    final second = await store.requestService(
        serviceId: id,
        quantity: 1,
        date: day,
        details: 'Récolte de légumes au champ');
    login(store, UserProfileType.provider);
    await store.transition(second.id, RecordStatus.declined);
    login(store, UserProfileType.farmer);
    expect(store.record(second.id)!.status, RecordStatus.declined);
  });

  test(
      'availability, request quantity, required detail and demo offers are enforced',
      () async {
    final id =
        await publish(store, available: day.add(const Duration(days: 5)));
    login(store, UserProfileType.farmer);
    for (final args in [
      (id, 1, day, 'Champ accessible de trois hectares'),
      (
        id,
        0,
        day.add(const Duration(days: 6)),
        'Champ accessible de trois hectares'
      ),
      (
        id,
        366,
        day.add(const Duration(days: 6)),
        'Champ accessible de trois hectares'
      ),
      (
        id,
        1,
        day.add(const Duration(days: 366)),
        'Champ accessible de trois hectares'
      ),
      (id, 1, day.add(const Duration(days: 6)), 'court'),
      ('demo-tractor', 1, day, 'Champ accessible de trois hectares'),
    ]) {
      await expectLater(
          store.requestService(
              serviceId: args.$1,
              quantity: args.$2,
              date: args.$3,
              details: args.$4),
          businessError);
    }
    expect(store.records(RecordKind.job), isEmpty);
  });

  test('failed cross-account request save changes neither participant',
      () async {
    final disk = _FailingPersistence();
    final local = MarketplaceStore(persistence: disk, clock: () => day);
    login(local, UserProfileType.provider);
    final id = await publish(local);
    final saved = disk.value;
    login(local, UserProfileType.farmer);
    disk.fail = true;
    await expectLater(
        local.requestService(
            serviceId: id,
            quantity: 1,
            date: day,
            details: 'Labour de mon champ'),
        businessError);
    expect(local.records(RecordKind.job), isEmpty);
    expect(disk.value, saved);
    login(local, UserProfileType.provider);
    expect(local.records(RecordKind.job), isEmpty);
  });

  test(
      'failed acceptance preserves pending status for both accounts after reload',
      () async {
    final disk = _FailingPersistence();
    final local = MarketplaceStore(persistence: disk, clock: () => day);
    login(local, UserProfileType.provider);
    final id = await publish(local);
    login(local, UserProfileType.farmer);
    final r = await local.requestService(
        serviceId: id, quantity: 1, date: day, details: 'Labour de mon champ');
    login(local, UserProfileType.provider);
    disk.fail = true;
    await expectLater(
        local.transition(r.id, RecordStatus.accepted), businessError);
    expect(local.record(r.id)!.status, RecordStatus.pending);
    final loaded = MarketplaceStore(persistence: disk);
    await loaded.load();
    login(loaded, UserProfileType.farmer);
    expect(loaded.record(r.id)!.status, RecordStatus.pending);
  });
}

class _FailingPersistence extends MemoryWorkspacePersistence {
  bool fail = false;
  @override
  Future<void> write(String value) async {
    if (fail) throw StateError('disk full');
    await super.write(value);
  }
}
