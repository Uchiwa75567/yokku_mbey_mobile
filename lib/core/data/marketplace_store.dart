import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/profile_selection/domain/entities/user_profile_type.dart';
import 'marketplace_models.dart';
import 'service_photos.dart';

abstract interface class WorkspacePersistence {
  Future<String?> read();
  Future<void> write(String value);
}

class LocalWorkspacePersistence implements WorkspacePersistence {
  final _preferences = SharedPreferencesAsync();
  static const _key = 'yokku_mbey.demo.workspace.v1';
  @override
  Future<String?> read() => _preferences.getString(_key);
  @override
  Future<void> write(String value) => _preferences.setString(_key, value);
}

class MemoryWorkspacePersistence implements WorkspacePersistence {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String value) async {
    this.value = value;
  }
}

class BusinessException implements Exception {
  const BusinessException(this.message);
  final String message;
  @override
  String toString() => message;
}

class MarketplaceStore extends ChangeNotifier {
  MarketplaceStore({required this.persistence, DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;
  final WorkspacePersistence persistence;
  final DateTime Function() _clock;
  Map<String, dynamic> _accounts = {};
  Map<String, String> _lastRoles = {};
  List<MarketRecord> _records = [];
  Set<String> _favorites = {};
  Map<String, String> _profile = {};
  String? _phone;
  UserProfileType? _role;
  String? _pendingPhone;
  DateTime? _otpExpiry;
  DateTime? _resendAt;
  int _attempts = 0;
  int _sequence = 0;
  int _sessionRevision = 0;
  bool _saving = false;
  String? loadError;

  String? get phone => _phone;
  int get resendSeconds => _resendAt == null
      ? 0
      : _resendAt!.difference(_clock()).inSeconds.clamp(0, 60);
  UserProfileType? get role => _role;
  bool get signedIn => _phone != null && _role != null;
  String get name => _profile['name'] ?? 'Mon compte';
  Map<String, String> get profile => Map.unmodifiable(_profile);
  bool isFavorite(String id) => _favorites.contains(id);
  List<MarketRecord> records(RecordKind kind) => List.unmodifiable(
      _records.where((r) => r.kind == kind).toList().reversed);
  MarketRecord? record(String id) {
    for (final r in _records) {
      if (r.id == id) return r;
    }
    return null;
  }

  Future<void> load() async {
    loadError = null;
    try {
      final raw = await persistence.read();
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        if (data['version'] != 1) {
          throw const FormatException('Version inconnue');
        }
        final accounts = Map<String, dynamic>.from(data['accounts'] as Map);
        for (final value in accounts.values) {
          final account = Map<String, dynamic>.from(value as Map);
          for (final record in account['records'] as List) {
            MarketRecord.fromJson(Map<String, dynamic>.from(record as Map));
          }
          Set<String>.from(account['favorites'] as List);
          Map<String, String>.from(account['profile'] as Map);
        }
        final lastRoles =
            Map<String, String>.from(data['lastRoles'] as Map? ?? {});
        final sequence = data['sequence'] as int;
        _accounts = accounts;
        _lastRoles = lastRoles;
        _sequence = sequence;
      }
    } catch (_) {
      loadError =
          'Les données locales ne peuvent pas être chargées. Réessayez avant de continuer.';
    }
    notifyListeners();
  }

  void requestCode(String phone) {
    final normalized = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (!RegExp(r'^\+2217[05678]\d{7}$').hasMatch(normalized)) {
      throw const BusinessException(
          'Saisissez un numéro mobile sénégalais valide.');
    }
    if (_pendingPhone == normalized &&
        _resendAt != null &&
        _clock().isBefore(_resendAt!)) {
      throw const BusinessException(
          'Patientez une minute avant de demander un nouveau code.');
    }
    _pendingPhone = normalized;
    _otpExpiry = _clock().add(const Duration(minutes: 5));
    _resendAt = _clock().add(const Duration(minutes: 1));
    _attempts = 0;
  }

  void verifyCode(String code) {
    if (_pendingPhone == null ||
        _otpExpiry == null ||
        !_clock().isBefore(_otpExpiry!)) {
      throw const BusinessException(
          'Le code a expiré. Demandez un nouveau code.');
    }
    if (_attempts >= 5) {
      throw const BusinessException(
          'Trop de tentatives. Demandez un nouveau code.');
    }
    _attempts++;
    if (code != '1234') {
      throw const BusinessException(
          'Code incorrect. Le code de démonstration est 1234.');
    }
    _phone = _pendingPhone;
    _pendingPhone = null;
    _otpExpiry = null;
    _sessionRevision++;
    _role = null;
    _records = [];
    _favorites = {};
    _profile = {};
    final remembered = _rememberedRole(_phone!);
    if (remembered != null) {
      selectRole(remembered);
    } else {
      notifyListeners();
    }
  }

  UserProfileType? _rememberedRole(String phone) {
    final saved = _lastRoles[phone];
    if (saved != null) {
      for (final role in UserProfileType.values) {
        if (role.name == saved) return role;
      }
      return null;
    }
    // Older workspaces did not save a preference. Only an unambiguous
    // existing account can be restored without asking the user to choose.
    final existing = UserProfileType.values
        .where((role) => _accounts.containsKey('$phone:${role.name}'));
    return existing.length == 1 ? existing.single : null;
  }

  Future<void> confirmRole(UserProfileType value) async {
    final phone = _phone;
    if (phone == null) {
      throw const BusinessException(
          'Connectez-vous pour choisir votre profil.');
    }
    if (loadError != null) throw BusinessException(loadError!);
    if (_saving) {
      throw const BusinessException(
          'Une sauvegarde est en cours. Patientez un instant.');
    }
    final revision = _sessionRevision;
    final lastRoles = {..._lastRoles, phone: value.name};
    _saving = true;
    try {
      try {
        await persistence.write(_encodeWorkspace(_accounts, lastRoles));
      } catch (_) {
        throw const BusinessException(
            'Votre choix n’a pas pu être enregistré. Réessayez.');
      }
      _lastRoles = lastRoles;
      if (_sessionRevision != revision || _phone != phone) {
        throw const BusinessException(
            'Votre session est terminée. Reconnectez-vous.');
      }
      selectRole(value);
    } finally {
      _saving = false;
    }
  }

  // Activate stored data; user-initiated changes go through confirmRole.
  void selectRole(UserProfileType value) {
    if (_phone == null) {
      throw const BusinessException(
          'Connectez-vous pour choisir votre profil.');
    }
    _role = value;
    final data = (_accounts['$_phone:${value.name}'] as Map?) ?? {};
    _records = (data['records'] as List? ?? [])
        .map((r) => MarketRecord.fromJson(Map<String, dynamic>.from(r as Map)))
        .toList();
    _favorites = Set<String>.from(data['favorites'] as List? ?? []);
    _profile = Map<String, String>.from(data['profile'] as Map? ?? {});
    notifyListeners();
  }

  void signOut() {
    _sessionRevision++;
    _phone = null;
    _role = null;
    _pendingPhone = null;
    _otpExpiry = null;
    _resendAt = null;
    _attempts = 0;
    _records = [];
    _favorites = {};
    _profile = {};
    notifyListeners();
  }

  void _require(UserProfileType expected) {
    if (!signedIn || _role != expected) {
      throw const BusinessException(
          'Cette action ne correspond pas à votre profil.');
    }
  }

  String _id(String prefix) =>
      '$prefix-${_clock().millisecondsSinceEpoch}-${++_sequence}';

  String _encodeWorkspace(
          Map<String, dynamic> accounts, Map<String, String> lastRoles) =>
      jsonEncode({
        'version': 1,
        'sequence': _sequence,
        'accounts': accounts,
        'lastRoles': lastRoles,
      });

  Future<void> _commit(
      {List<MarketRecord>? records,
      Set<String>? favorites,
      Map<String, String>? profile,
      Map<String, List<MarketRecord>> linkedRecords = const {}}) async {
    if (!signedIn) {
      throw const BusinessException(
          'Votre session est terminée. Reconnectez-vous.');
    }
    if (loadError != null) throw BusinessException(loadError!);
    if (_saving) {
      throw const BusinessException(
          'Une sauvegarde est en cours. Patientez un instant.');
    }
    _saving = true;
    final revision = _sessionRevision;
    final accountKey = '$_phone:${_role!.name}';
    final nextRecords = records ?? _records;
    final nextFavorites = favorites ?? _favorites;
    final nextProfile = profile ?? _profile;
    final accounts = {
      ..._accounts,
      for (final entry in linkedRecords.entries)
        entry.key: {
          ...Map<String, dynamic>.from(_accounts[entry.key] as Map),
          'records': entry.value.map((r) => r.toJson()).toList()
        },
      accountKey: {
        'records': nextRecords.map((r) => r.toJson()).toList(),
        'favorites': nextFavorites.toList(),
        'profile': nextProfile,
      }
    };
    try {
      await persistence.write(_encodeWorkspace(accounts, _lastRoles));
      _accounts = accounts;
      // A pending save must never reopen an account after logout.
      if (_sessionRevision == revision &&
          '$_phone:${_role?.name}' == accountKey) {
        _records = nextRecords;
        _favorites = nextFavorites;
        _profile = nextProfile;
        notifyListeners();
      }
    } catch (_) {
      throw const BusinessException(
          'Sauvegarde impossible. Vos modifications ne sont pas enregistrées. Réessayez.');
    } finally {
      _saving = false;
    }
  }

  Future<void> toggleFavorite(String id) async {
    _require(UserProfileType.buyer);
    MarketplaceCatalog.product(id);
    final next = {..._favorites};
    if (!next.add(id)) next.remove(id);
    await _commit(favorites: next);
  }

  int remainingStock(ProductListing product) {
    final currentKey = '$_phone:${_role?.name}';
    final orders = <MarketRecord>[
      ...records(RecordKind.order),
      for (final account in _accounts.entries.where((a) => a.key != currentKey))
        for (final value in (account.value as Map)['records'] as List)
          MarketRecord.fromJson(Map<String, dynamic>.from(value as Map)),
    ];
    return product.stock -
        orders
            .where((r) =>
                r.kind == RecordKind.order &&
                r.relatedId == product.id &&
                r.status != RecordStatus.cancelled)
            .fold(0, (sum, r) => sum + r.quantity);
  }

  Future<MarketRecord> reserve(
      {required String productId,
      required int quantity,
      required String recovery,
      String addressId = ''}) async {
    _require(UserProfileType.buyer);
    final product = MarketplaceCatalog.product(productId);
    if (quantity < product.minimum || quantity > remainingStock(product)) {
      throw BusinessException(
          'Quantité autorisée : ${product.minimum} à ${remainingStock(product)} kg.');
    }
    if (!['Retrait', 'Livraison'].contains(recovery)) {
      throw const BusinessException('Choisissez un mode de réception.');
    }
    final address = record(addressId);
    if (recovery == 'Livraison' &&
        (address == null || address.kind != RecordKind.address)) {
      throw const BusinessException('Ajoutez une adresse de livraison.');
    }
    final result = MarketRecord(
        id: _id('YB'),
        kind: RecordKind.order,
        title: product.name,
        relatedId: product.id,
        createdAt: _clock(),
        amount: quantity * product.unitPrice,
        quantity: quantity,
        region: product.region,
        attributes: {
          'recovery': recovery,
          'producer': product.producer,
          'unitPrice': '${product.unitPrice}',
          'address': recovery == 'Livraison'
              ? '${address!.title}, ${address.details}, ${address.region}'
              : '',
          'payment': 'À convenir avec le producteur',
          'preReservation': '${product.availableSoon}',
        });
    await _commit(records: [..._records, result]);
    return result;
  }

  Future<void> saveNeed(
      {String? id,
      required String title,
      required int quantity,
      required String unit,
      required String region,
      required int budget,
      required DateTime date,
      required String details}) async {
    _require(UserProfileType.buyer);
    if (title.trim().isEmpty ||
        quantity <= 0 ||
        budget <= 0 ||
        region.trim().isEmpty) {
      throw const BusinessException(
          'Renseignez un produit, une quantité, une région et un budget valides.');
    }
    final today = DateUtils.dateOnly(_clock());
    if (DateUtils.dateOnly(date).isBefore(today)) {
      throw const BusinessException('Choisissez une date à venir.');
    }
    final old = id == null ? null : record(id);
    if (id != null &&
        (old == null ||
            old.kind != RecordKind.need ||
            old.status != RecordStatus.active)) {
      throw const BusinessException(
          'Cette demande ne peut plus être modifiée.');
    }
    final result = MarketRecord(
        id: id ?? _id('BES'),
        kind: RecordKind.need,
        title: title.trim(),
        status: RecordStatus.active,
        createdAt: old?.createdAt ?? _clock(),
        quantity: quantity,
        region: region,
        amount: budget,
        details: details.trim(),
        attributes: {'unit': unit, 'date': date.toIso8601String()});
    await _commit(records: [..._records.where((r) => r.id != id), result]);
  }

  Future<MarketRecord> invest(
      {required String projectId,
      required int amount,
      required String message,
      required bool consent}) async {
    _require(UserProfileType.investor);
    final project = MarketplaceCatalog.project(projectId);
    if (!consent) {
      throw const BusinessException('Confirmez avoir consulté les conditions.');
    }
    if (amount < project.minimum || amount > project.remaining) {
      throw BusinessException(
          'Montant autorisé : ${formatCfa(project.minimum)} à ${formatCfa(project.remaining)}.');
    }
    if (records(RecordKind.investment).any((r) =>
        r.relatedId == projectId && r.status != RecordStatus.cancelled)) {
      throw const BusinessException(
          'Vous avez déjà une intention ouverte pour ce projet. Consultez vos financements.');
    }
    final result = MarketRecord(
        id: _id('FIN'),
        kind: RecordKind.investment,
        title: project.name,
        relatedId: projectId,
        createdAt: _clock(),
        amount: amount,
        region: project.region,
        details: message.trim(),
        attributes: {'owner': project.owner});
    await _commit(records: [..._records, result]);
    return result;
  }

  Future<void> saveService(
      {String? id,
      required String title,
      required String category,
      required String region,
      required int price,
      required String unit,
      required String details,
      ServiceType serviceType = ServiceType.technical,
      List<String> photos = const [],
      String experience = '',
      int teamSize = 1,
      DateTime? availableFrom}) async {
    _require(UserProfileType.provider);
    if (title.trim().isEmpty ||
        price <= 0 ||
        region.isEmpty ||
        details.trim().isEmpty ||
        !MarketplaceCatalog.categoriesFor(serviceType).contains(category) ||
        !MarketplaceCatalog.unitsFor(serviceType).contains(unit) ||
        !MarketplaceCatalog.regions.skip(1).contains(region) ||
        teamSize < 1 ||
        teamSize > 100) {
      throw const BusinessException(
          'Complétez le service avec un tarif positif et une description.');
    }
    final old = id == null ? null : record(id);
    if (id != null && (old == null || old.kind != RecordKind.service)) {
      throw const BusinessException('Service introuvable.');
    }
    try {
      validateServicePhotos(photos);
    } on FormatException catch (e) {
      throw BusinessException(e.message);
    }
    if (serviceType == ServiceType.technical &&
        ['Tracteur', 'Matériel'].contains(category) &&
        photos.isEmpty) {
      throw const BusinessException(
          'Ajoutez au moins une photo de votre matériel.');
    }
    if (serviceType == ServiceType.workforce && experience.trim().isEmpty) {
      throw const BusinessException(
          'Décrivez vos compétences ou votre expérience agricole.');
    }
    if (availableFrom != null &&
        DateUtils.dateOnly(availableFrom).isAfter(
            DateUtils.dateOnly(_clock()).add(const Duration(days: 365)))) {
      throw const BusinessException(
          'Choisissez une disponibilité dans les 12 prochains mois.');
    }
    final result = MarketRecord(
        id: id ?? _id('SER'),
        kind: RecordKind.service,
        title: title.trim(),
        createdAt: old?.createdAt ?? _clock(),
        status: old?.status ?? RecordStatus.active,
        amount: price,
        region: region,
        details: details.trim(),
        photos: photos,
        attributes: {
          'category': category,
          'unit': unit,
          'serviceType': serviceType.name,
          'experience': experience.trim(),
          'teamSize': '$teamSize',
          if (availableFrom != null)
            'availableFrom': DateUtils.dateOnly(availableFrom).toIso8601String()
        });
    await _commit(records: [..._records.where((r) => r.id != id), result]);
  }

  List<PublishedService> publishedServices({bool includeExamples = true}) {
    if (!signedIn ||
        ![UserProfileType.farmer, UserProfileType.provider].contains(role)) {
      return [];
    }
    final currentKey = '$_phone:${_role!.name}';
    final result = <PublishedService>[];
    if (role == UserProfileType.provider) {
      result.addAll(records(RecordKind.service)
          .where((r) =>
              r.status == RecordStatus.active &&
              (!r.needsPhoto || r.photos.isNotEmpty))
          .map((r) => PublishedService(
              record: r,
              providerName: name == 'Mon compte' ? 'Prestataire' : name)));
    }
    for (final entry in _accounts.entries) {
      if (!entry.key.endsWith(':provider') || entry.key == currentKey) continue;
      final account = entry.value as Map;
      final providerName =
          (account['profile'] as Map)['name'] as String? ?? 'Prestataire';
      result.addAll(_accountRecords(entry.key)
          .where((r) =>
              r.kind == RecordKind.service &&
              r.status == RecordStatus.active &&
              (!r.needsPhoto || r.photos.isNotEmpty))
          .map((r) => PublishedService(record: r, providerName: providerName)));
    }
    if (includeExamples) result.addAll(MarketplaceCatalog.serviceExamples);
    return List.unmodifiable(result);
  }

  PublishedService? publishedService(String id) =>
      publishedServices().where((s) => s.record.id == id).firstOrNull;

  List<MarketRecord> _accountRecords(String key) =>
      ((_accounts[key] as Map?)?['records'] as List? ?? const [])
          .map(
              (r) => MarketRecord.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList();

  Future<MarketRecord> requestService(
      {required String serviceId,
      required int quantity,
      required DateTime date,
      required String details}) async {
    _require(UserProfileType.farmer);
    final offer = publishedService(serviceId);
    if (offer == null || offer.isDemo) {
      throw const BusinessException(
          'Cette offre ne peut pas recevoir de demande.');
    }
    final service = offer.record;
    final providerKey = _accounts.keys
        .where((key) =>
            key.endsWith(':provider') &&
            _accountRecords(key)
                .any((r) => r.id == serviceId && r.kind == RecordKind.service))
        .firstOrNull;
    final day = DateUtils.dateOnly(date);
    final available =
        DateTime.tryParse(service.attributes['availableFrom'] ?? '');
    if (providerKey == null ||
        quantity < 1 ||
        quantity > 365 ||
        details.trim().length < 10 ||
        day.isBefore(DateUtils.dateOnly(_clock())) ||
        day.isAfter(
            DateUtils.dateOnly(_clock()).add(const Duration(days: 365))) ||
        (available != null && day.isBefore(available))) {
      throw const BusinessException(
          'Vérifiez la disponibilité, la quantité et décrivez le travail en au moins 10 caractères.');
    }
    if (records(RecordKind.job).any((r) =>
        r.relatedId == serviceId &&
        [RecordStatus.pending, RecordStatus.accepted, RecordStatus.active]
            .contains(r.status))) {
      throw const BusinessException(
          'Une demande est déjà ouverte pour cette offre. Consultez son suivi.');
    }
    final request = MarketRecord(
        id: _id('MIS'),
        kind: RecordKind.job,
        title: service.title,
        relatedId: serviceId,
        createdAt: _clock(),
        amount: quantity * service.amount,
        quantity: quantity,
        region: service.region,
        details: details.trim(),
        attributes: {
          'source': 'direct',
          'providerAccount': providerKey,
          'farmerAccount': '$_phone:farmer',
          'provider': offer.providerName,
          'client': name == 'Mon compte' ? 'Agriculteur' : name,
          'serviceType': service.serviceType.name,
          'category': service.attributes['category']!,
          'unit': service.attributes['unit']!,
          'unitPrice': '${service.amount}',
          'date': day.toIso8601String(),
        });
    await _commit(records: [
      ..._records,
      request
    ], linkedRecords: {
      providerKey: [..._accountRecords(providerKey), request]
    });
    return request;
  }

  Future<void> _transitionServiceRequest(
      MarketRecord item, RecordStatus status) async {
    final key = '$_phone:${_role?.name}';
    final provider = role == UserProfileType.provider &&
        item.attributes['providerAccount'] == key;
    final farmer = role == UserProfileType.farmer &&
        item.attributes['farmerAccount'] == key;
    final allowed = (provider &&
            ((item.status == RecordStatus.pending &&
                    [RecordStatus.accepted, RecordStatus.declined]
                        .contains(status)) ||
                (item.status == RecordStatus.accepted &&
                    status == RecordStatus.active) ||
                (item.status == RecordStatus.active &&
                    status == RecordStatus.completed))) ||
        (farmer &&
            item.status == RecordStatus.pending &&
            status == RecordStatus.cancelled);
    if (!allowed) {
      throw const BusinessException(
          'Ce changement de statut n’est pas autorisé.');
    }
    final otherKey =
        item.attributes[provider ? 'farmerAccount' : 'providerAccount']!;
    final other = _accountRecords(otherKey);
    if (!other.any((r) => r.id == item.id && r.status == item.status)) {
      throw const BusinessException(
          'Le suivi a changé. Reconnectez-vous pour actualiser la demande.');
    }
    await _commit(
        records: _records
            .map((r) => r.id == item.id ? r.withStatus(status) : r)
            .toList(),
        linkedRecords: {
          otherKey: other
              .map((r) => r.id == item.id ? r.withStatus(status) : r)
              .toList()
        });
  }

  Future<MarketRecord> quote(
      {required String requestId,
      required String serviceId,
      required int amount,
      required DateTime date,
      required String details}) async {
    _require(UserProfileType.provider);
    final request = MarketplaceCatalog.request(requestId);
    final service = record(serviceId);
    if (service == null ||
        service.kind != RecordKind.service ||
        service.status != RecordStatus.active ||
        service.attributes['category'] != request.category) {
      throw const BusinessException(
          'Choisissez un service actif de la même catégorie.');
    }
    if (amount <= 0 ||
        details.trim().isEmpty ||
        DateUtils.dateOnly(date).isBefore(DateUtils.dateOnly(_clock()))) {
      throw const BusinessException(
          'Renseignez un prix positif, une date à venir et le contenu du devis.');
    }
    if (records(RecordKind.job).any((r) =>
        r.relatedId == requestId &&
        r.status != RecordStatus.cancelled &&
        r.status != RecordStatus.declined)) {
      throw const BusinessException('Un devis existe déjà pour cette demande.');
    }
    final result = MarketRecord(
        id: _id('DEV'),
        kind: RecordKind.job,
        title: request.title,
        relatedId: requestId,
        createdAt: _clock(),
        amount: amount,
        region: request.region,
        details: details.trim(),
        attributes: {
          'client': request.client,
          'serviceId': serviceId,
          'date': date.toIso8601String()
        });
    await _commit(records: [..._records, result]);
    return result;
  }

  Future<void> transition(String id, RecordStatus status) async {
    final item = record(id);
    if (item == null) throw const BusinessException('Élément introuvable.');
    if (item.kind == RecordKind.job && item.attributes['source'] == 'direct') {
      await _transitionServiceRequest(item, status);
      return;
    }
    if (item.kind == RecordKind.service &&
        status == RecordStatus.active &&
        item.needsPhoto &&
        item.photos.isEmpty) {
      throw const BusinessException(
          'Ajoutez une photo du matériel avant de réactiver cette offre.');
    }
    final allowed = switch (item.kind) {
      RecordKind.order => _role == UserProfileType.buyer &&
          ((item.status == RecordStatus.pending &&
                  status == RecordStatus.cancelled) ||
              (item.status == RecordStatus.active &&
                  status == RecordStatus.completed)),
      RecordKind.need => _role == UserProfileType.buyer &&
          item.status == RecordStatus.active &&
          status == RecordStatus.closed,
      RecordKind.investment => _role == UserProfileType.investor &&
          item.status == RecordStatus.pending &&
          status == RecordStatus.cancelled,
      RecordKind.service => _role == UserProfileType.provider &&
          ((item.status == RecordStatus.active &&
                  status == RecordStatus.paused) ||
              (item.status == RecordStatus.paused &&
                  status == RecordStatus.active)),
      RecordKind.job => _role == UserProfileType.provider &&
          ((item.status == RecordStatus.pending &&
                  status == RecordStatus.cancelled) ||
              (item.status == RecordStatus.accepted &&
                  status == RecordStatus.active) ||
              (item.status == RecordStatus.active &&
                  status == RecordStatus.completed)),
      RecordKind.alert => _role == UserProfileType.buyer &&
          ((item.status == RecordStatus.active &&
                  status == RecordStatus.paused) ||
              (item.status == RecordStatus.paused &&
                  status == RecordStatus.active)),
      _ => false,
    };
    if (!allowed) {
      throw const BusinessException(
          'Ce changement de statut n’est pas autorisé.');
    }
    await _commit(
        records: _records
            .map((r) => r.id == id ? r.withStatus(status) : r)
            .toList());
  }

  Future<void> saveProfile(Map<String, String> values) async {
    if ((values['name'] ?? '').trim().isEmpty) {
      throw const BusinessException('Indiquez votre nom.');
    }
    await _commit(
        profile: {..._profile, ...values.map((k, v) => MapEntry(k, v.trim()))});
  }

  Future<void> saveAddress(
      {String? id,
      required String name,
      required String region,
      required String details}) async {
    _require(UserProfileType.buyer);
    if (name.trim().isEmpty ||
        region.trim().isEmpty ||
        details.trim().isEmpty) {
      throw const BusinessException('Complétez l’adresse.');
    }
    if (id != null && record(id)?.kind != RecordKind.address) {
      throw const BusinessException('Adresse introuvable.');
    }
    final result = MarketRecord(
        id: id ?? _id('ADR'),
        kind: RecordKind.address,
        title: name.trim(),
        region: region.trim(),
        details: details.trim(),
        createdAt: _clock(),
        status: RecordStatus.active);
    await _commit(records: [..._records.where((r) => r.id != id), result]);
  }

  Future<void> removeAddress(String id) async {
    _require(UserProfileType.buyer);
    if (record(id)?.kind != RecordKind.address) {
      throw const BusinessException('Adresse introuvable.');
    }
    await _commit(records: _records.where((r) => r.id != id).toList());
  }

  Future<void> saveAlert(
      {required String product,
      required String region,
      required int maxPrice}) async {
    _require(UserProfileType.buyer);
    if (product.trim().isEmpty || maxPrice <= 0) {
      throw const BusinessException(
          'Renseignez un produit et un prix maximal positif.');
    }
    final result = MarketRecord(
        id: _id('ALT'),
        kind: RecordKind.alert,
        title: product.trim(),
        region: region,
        amount: maxPrice,
        createdAt: _clock(),
        status: RecordStatus.active);
    await _commit(records: [..._records, result]);
  }

  Future<void> report(
      {required String title,
      required String details,
      String orderId = ''}) async {
    if (title.trim().isEmpty || details.trim().length < 10) {
      throw const BusinessException(
          'Décrivez le problème en au moins 10 caractères.');
    }
    if (orderId.isNotEmpty && record(orderId)?.kind != RecordKind.order) {
      throw const BusinessException('Commande introuvable.');
    }
    final result = MarketRecord(
        id: _id('SUP'),
        kind: RecordKind.issue,
        title: title.trim(),
        relatedId: orderId,
        details: details.trim(),
        createdAt: _clock());
    await _commit(records: [..._records, result]);
  }

  Future<void> review(
      {required String orderId,
      required int stars,
      required String details}) async {
    _require(UserProfileType.buyer);
    final order = record(orderId);
    if (order?.kind != RecordKind.order ||
        order?.status != RecordStatus.completed) {
      throw const BusinessException(
          'Vous pouvez noter uniquement un achat terminé.');
    }
    if (stars < 1 ||
        stars > 5 ||
        records(RecordKind.review).any((r) => r.relatedId == orderId)) {
      throw const BusinessException(
          'Choisissez une note. Un seul avis est autorisé par achat.');
    }
    final result = MarketRecord(
        id: _id('AVI'),
        kind: RecordKind.review,
        title: order!.title,
        relatedId: orderId,
        quantity: stars,
        details: details.trim(),
        createdAt: _clock(),
        status: RecordStatus.completed);
    await _commit(records: [..._records, result]);
  }
}

class MarketplaceScope extends InheritedNotifier<MarketplaceStore> {
  const MarketplaceScope(
      {required MarketplaceStore store, required super.child, super.key})
      : super(notifier: store);
  static MarketplaceStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MarketplaceScope>()!.notifier!;
  static MarketplaceStore? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MarketplaceScope>()?.notifier;
}
