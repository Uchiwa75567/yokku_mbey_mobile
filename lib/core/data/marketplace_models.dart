import '../../features/profile_selection/domain/entities/user_profile_type.dart';

enum RecordKind {
  order,
  need,
  investment,
  service,
  job,
  address,
  alert,
  issue,
  review
}

enum RecordStatus {
  pending,
  accepted,
  active,
  completed,
  cancelled,
  declined,
  paused,
  closed
}

extension RecordStatusLabel on RecordStatus {
  String get label => switch (this) {
        RecordStatus.pending => 'En attente',
        RecordStatus.accepted => 'Acceptée',
        RecordStatus.active => 'En cours',
        RecordStatus.completed => 'Terminée',
        RecordStatus.cancelled => 'Annulée',
        RecordStatus.declined => 'Déclinée',
        RecordStatus.paused => 'En pause',
        RecordStatus.closed => 'Clôturée',
      };
}

extension ProfileLabel on UserProfileType {
  String get label => switch (this) {
        UserProfileType.farmer => 'Agriculteur',
        UserProfileType.buyer => 'Acheteur',
        UserProfileType.investor => 'Investisseur',
        UserProfileType.provider => 'Prestataire',
      };
}

class MarketRecord {
  MarketRecord(
      {required this.id,
      required this.kind,
      required this.title,
      required this.createdAt,
      this.status = RecordStatus.pending,
      this.relatedId = '',
      this.region = '',
      this.amount = 0,
      this.quantity = 0,
      this.details = '',
      List<String> photos = const [],
      Map<String, String> attributes = const {}})
      : attributes = Map.unmodifiable(attributes),
        photos = List.unmodifiable(photos);

  final String id;
  final RecordKind kind;
  final String title;
  final DateTime createdAt;
  final RecordStatus status;
  final String relatedId;
  final String region;
  final int amount;
  final int quantity;
  final String details;
  final Map<String, String> attributes;
  final List<String> photos;

  MarketRecord withStatus(RecordStatus value) => MarketRecord(
      id: id,
      kind: kind,
      title: title,
      createdAt: createdAt,
      status: value,
      relatedId: relatedId,
      region: region,
      amount: amount,
      quantity: quantity,
      details: details,
      photos: photos,
      attributes: attributes);

  Map<String, Object?> toJson() => {
        'id': id,
        'kind': kind.name,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'relatedId': relatedId,
        'region': region,
        'amount': amount,
        'quantity': quantity,
        'details': details,
        'photos': photos,
        'attributes': attributes
      };

  factory MarketRecord.fromJson(Map<String, dynamic> json) => MarketRecord(
      id: json['id'] as String,
      kind: RecordKind.values.byName(json['kind'] as String),
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: RecordStatus.values.byName(json['status'] as String),
      relatedId: json['relatedId'] as String,
      region: json['region'] as String,
      amount: json['amount'] as int,
      quantity: json['quantity'] as int,
      details: json['details'] as String,
      photos: List<String>.from(json['photos'] as List? ?? const []),
      attributes: Map<String, String>.from(json['attributes'] as Map));
}

enum ServiceType { technical, workforce }

extension ServiceTypeLabel on ServiceType {
  String get label =>
      this == ServiceType.workforce ? 'Travail agricole' : 'Service technique';
}

extension ServiceRecord on MarketRecord {
  ServiceType get serviceType => attributes['serviceType'] == 'workforce'
      ? ServiceType.workforce
      : ServiceType.technical;
  bool get needsPhoto =>
      serviceType == ServiceType.technical &&
      ['Tracteur', 'Matériel'].contains(attributes['category']);
}

class PublishedService {
  const PublishedService(
      {required this.record, required this.providerName, this.isDemo = false});
  final MarketRecord record;
  final String providerName;
  final bool isDemo;
}

class ProductListing {
  const ProductListing(
      {required this.id,
      required this.name,
      required this.category,
      required this.region,
      required this.producer,
      required this.image,
      required this.unitPrice,
      required this.stock,
      required this.minimum,
      this.availableSoon = false});
  final String id, name, category, region, producer, image;
  final int unitPrice, stock, minimum;
  final bool availableSoon;
}

class ProjectListing {
  const ProjectListing(
      {required this.id,
      required this.name,
      required this.region,
      required this.owner,
      required this.category,
      required this.image,
      required this.target,
      required this.raised,
      required this.minimum,
      required this.description,
      required this.useOfFunds,
      required this.durationMonths,
      required this.beneficiaries});
  final String id,
      name,
      region,
      owner,
      category,
      image,
      description,
      useOfFunds;
  final int target, raised, minimum, durationMonths, beneficiaries;
  int get remaining => target - raised;
}

class ClientRequest {
  const ClientRequest(
      {required this.id,
      required this.title,
      required this.client,
      required this.region,
      required this.category,
      required this.budget,
      required this.description,
      required this.daysFromNow});
  final String id, title, client, region, category, description;
  final int budget, daysFromNow;
}

abstract final class MarketplaceCatalog {
  static const regions = [
    'Toutes les régions',
    'Dakar',
    'Thiès',
    'Kaolack',
    'Saint-Louis',
    'Fatick'
  ];
  static const serviceCategories = [
    'Transport',
    'Tracteur',
    'Irrigation',
    'Semences',
    'Conseil',
    'Matériel',
  ];
  static const laborCategories = [
    'Récolte',
    'Semis',
    'Désherbage',
    'Préparation du sol'
  ];
  static List<String> categoriesFor(ServiceType type) =>
      type == ServiceType.workforce ? laborCategories : serviceCategories;
  static List<String> unitsFor(ServiceType type) =>
      type == ServiceType.workforce
          ? const ['jour', 'heure', 'hectare']
          : const ['jour', 'trajet', 'hectare', 'prestation', 'kg'];
  static const tractorImage = 'assets/images/service_tractor_demo.png';
  static List<PublishedService> get serviceExamples => [
        PublishedService(
            isDemo: true,
            providerName: 'Exemple de prestataire',
            record: MarketRecord(
                id: 'demo-tractor',
                kind: RecordKind.service,
                title: 'Tracteur avec conducteur',
                createdAt: DateTime(2026),
                status: RecordStatus.active,
                region: 'Kaolack',
                amount: 40000,
                details:
                    'Labour et préparation du sol. Conducteur et charrue inclus. Carburant à convenir.',
                photos: const [
                  tractorImage
                ],
                attributes: const {
                  'serviceType': 'technical',
                  'category': 'Tracteur',
                  'unit': 'hectare'
                })),
        PublishedService(
            isDemo: true,
            providerName: 'Exemple d’ouvrier agricole',
            record: MarketRecord(
                id: 'demo-worker',
                kind: RecordKind.service,
                title: 'Ouvrier pour la récolte',
                createdAt: DateTime(2026),
                status: RecordStatus.active,
                region: 'Thiès',
                amount: 5000,
                details:
                    'Récolte, tri et mise en caisse des légumes. Disponible pour travailler dans les champs.',
                attributes: const {
                  'serviceType': 'workforce',
                  'category': 'Récolte',
                  'unit': 'jour',
                  'teamSize': '1',
                  'experience': '3 campagnes agricoles'
                })),
      ];
  static const products = [
    ProductListing(
        id: 'tomato',
        name: 'Tomate fraîche',
        category: 'Légumes',
        region: 'Kaolack',
        producer: 'Moussa Diop',
        image: 'assets/images/buyer_home_tomato.png',
        unitPrice: 400,
        stock: 500,
        minimum: 50),
    ProductListing(
        id: 'onion',
        name: 'Oignon local',
        category: 'Légumes',
        region: 'Thiès',
        producer: 'Coopérative des Niayes',
        image: 'assets/images/buyer_onion.png',
        unitPrice: 350,
        stock: 1200,
        minimum: 25),
    ProductListing(
        id: 'potato',
        name: 'Pomme de terre',
        category: 'Tubercules',
        region: 'Saint-Louis',
        producer: 'Aïssatou Fall',
        image: 'assets/images/buyer_potato.png',
        unitPrice: 500,
        stock: 800,
        minimum: 50),
    ProductListing(
        id: 'corn',
        name: 'Maïs',
        category: 'Céréales',
        region: 'Fatick',
        producer: 'GIE Suxali',
        image: 'assets/images/buyer_corn.png',
        unitPrice: 250,
        stock: 2000,
        minimum: 100,
        availableSoon: true),
  ];
  static const projects = [
    ProjectListing(
        id: 'irrigation',
        name: 'Irrigation des Niayes',
        region: 'Thiès',
        owner: 'Coopérative des Niayes',
        category: 'Irrigation',
        image: 'assets/images/farmer_home_background.png',
        target: 3000000,
        raised: 1800000,
        minimum: 50000,
        durationMonths: 12,
        beneficiaries: 24,
        description:
            'Équiper six hectares en irrigation goutte à goutte pour sécuriser la production maraîchère.',
        useOfFunds:
            'Pompe et forage : 50 %\nRéseau goutte à goutte : 35 %\nInstallation et formation : 15 %'),
    ProjectListing(
        id: 'storage',
        name: 'Stockage de la récolte',
        region: 'Kaolack',
        owner: 'GIE Suxali',
        category: 'Équipement',
        image: 'assets/images/farmer_tomato_harvest.png',
        target: 2000000,
        raised: 650000,
        minimum: 25000,
        durationMonths: 8,
        beneficiaries: 18,
        description:
            'Aménager un magasin ventilé pour réduire les pertes après récolte et mutualiser le stockage.',
        useOfFunds:
            'Aménagement : 60 %\nCaisses et rayonnages : 30 %\nFormation : 10 %'),
    ProjectListing(
        id: 'seeds',
        name: 'Semences pour la prochaine campagne',
        region: 'Fatick',
        owner: 'Union des producteurs de Fatick',
        category: 'Semences',
        image: 'assets/images/buyer_corn.png',
        target: 1500000,
        raised: 400000,
        minimum: 25000,
        durationMonths: 6,
        beneficiaries: 32,
        description:
            'Acquérir des semences et organiser un accompagnement technique pour la prochaine campagne.',
        useOfFunds: 'Semences : 70 %\nIntrants : 20 %\nAccompagnement : 10 %'),
  ];
  static const requests = [
    ClientRequest(
        id: 'harvest-work',
        title: 'Ouvriers pour une récolte de légumes',
        client: 'Maraîchers des Niayes',
        region: 'Thiès',
        category: 'Récolte',
        budget: 30000,
        daysFromNow: 5,
        description:
            'Recherche de main-d’œuvre pour récolter, trier et mettre en caisse les légumes. Précisez vos disponibilités et votre tarif.'),
    ClientRequest(
        id: 'transport',
        title: 'Transport de 2 tonnes d’oignons',
        client: 'Coopérative des Niayes',
        region: 'Thiès',
        category: 'Transport',
        budget: 85000,
        daysFromNow: 4,
        description:
            'Acheminement de Thiès à Dakar. Camion couvert, chargement le matin. Le devis doit inclure le carburant.'),
    ClientRequest(
        id: 'tractor',
        title: 'Labour de 3 hectares',
        client: 'Moussa Diop',
        region: 'Kaolack',
        category: 'Tracteur',
        budget: 120000,
        daysFromNow: 7,
        description:
            'Préparation du sol sur une parcelle accessible. Tracteur avec conducteur et charrue nécessaires.'),
    ClientRequest(
        id: 'pump',
        title: 'Installation d’une pompe solaire',
        client: 'Aïssatou Fall',
        region: 'Saint-Louis',
        category: 'Irrigation',
        budget: 200000,
        daysFromNow: 10,
        description:
            'Diagnostic du forage et pose d’une pompe solaire. Préciser les fournitures comprises dans le devis.'),
  ];
  static ProductListing product(String id) =>
      products.firstWhere((p) => p.id == id);
  static ProjectListing project(String id) =>
      projects.firstWhere((p) => p.id == id);
  static ClientRequest request(String id) =>
      requests.firstWhere((p) => p.id == id);
}

String formatCfa(int amount) =>
    '${amount.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (_) => ' ')} FCFA';
String formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
