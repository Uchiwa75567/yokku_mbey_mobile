import 'package:flutter/material.dart';
import '../../../../core/data/marketplace_models.dart';
import '../../../../core/data/marketplace_store.dart';
import '../../../../core/widgets/journey_scaffold.dart';
import '../../../account/presentation/account_pages.dart';
import '../../../../core/widgets/service_photo_field.dart';
import 'service_directory_pages.dart';

class ProviderServicesPage extends StatelessWidget {
  const ProviderServicesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.of(context);
    final services = store.records(RecordKind.service);
    return JourneyScaffold(
        title: 'Mes offres',
        subtitle: 'Travail agricole, matériel et services techniques.',
        root: true,
        tab: 1,
        children: [
          JourneyButton(
              label: 'Ajouter un service',
              icon: Icons.add,
              onPressed: () async =>
                  openJourney(context, '/provider-service-form')),
          if (services.isEmpty)
            const JourneyEmpty(
                title: 'Présentez votre activité',
                message:
                    'Proposez votre travail dans les champs ou une prestation technique.'),
          ...services.map((r) => ServiceOfferCard(
              offer: PublishedService(record: r, providerName: store.name))),
          const JourneyNotice(
              'Les offres actives sont visibles par les agriculteurs connectés sur cet appareil.'),
        ]);
  }
}

class ProviderServiceFormPage extends StatefulWidget {
  const ProviderServiceFormPage({this.serviceId, super.key});
  static const routeName = '/provider-service-form';
  final String? serviceId;
  @override
  State<ProviderServiceFormPage> createState() =>
      _ProviderServiceFormPageState();
}

class _ProviderServiceFormPageState extends State<ProviderServiceFormPage> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController(),
      _price = TextEditingController(),
      _details = TextEditingController(),
      _experience = TextEditingController();
  String _category = 'Transport', _region = 'Thiès', _unit = 'trajet';
  ServiceType _type = ServiceType.technical;
  List<String> _photos = [];
  int _teamSize = 1;
  DateTime _available = DateUtils.dateOnly(DateTime.now());
  bool _loaded = false, _photoBusy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    if (widget.serviceId == 'new-workforce') {
      _type = ServiceType.workforce;
      _category = MarketplaceCatalog.laborCategories.first;
      _unit = 'jour';
    }
    final old = MarketplaceScope.of(context).record(widget.serviceId ?? '');
    if (old?.kind == RecordKind.service) {
      _title.text = old!.title;
      _price.text = '${old.amount}';
      _details.text = old.details;
      _region = old.region;
      _category = old.attributes['category']!;
      _unit = old.attributes['unit']!;
      _type = old.serviceType;
      _photos = [...old.photos];
      _experience.text = old.attributes['experience'] ?? '';
      _teamSize = int.tryParse(old.attributes['teamSize'] ?? '') ?? 1;
      _available = DateTime.tryParse(old.attributes['availableFrom'] ?? '') ??
          _available;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _details.dispose();
    _experience.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.of(context);
    final worker = _type == ServiceType.workforce;
    return Form(
        key: _form,
        child: JourneyScaffold(
            title:
                widget.serviceId == null || widget.serviceId == 'new-workforce'
                    ? 'Ajouter un service'
                    : 'Modifier mon offre',
            children: [
              const JourneyHeading('Je propose'),
              SegmentedButton<ServiceType>(
                  segments: const [
                    ButtonSegment(
                        value: ServiceType.technical,
                        icon: Icon(Icons.agriculture_outlined),
                        label: Text('Technique')),
                    ButtonSegment(
                        value: ServiceType.workforce,
                        icon: Icon(Icons.person_outline),
                        label: Text('Ouvrier')),
                  ],
                  selected: {
                    _type
                  },
                  showSelectedIcon: false,
                  onSelectionChanged: (values) => setState(() {
                        _type = values.single;
                        _category =
                            MarketplaceCatalog.categoriesFor(_type).first;
                        _unit = MarketplaceCatalog.unitsFor(_type).first;
                      })),
              Text(
                  worker
                      ? 'Travail dans les champs, seul ou en équipe.'
                      : 'Location de matériel ou prestation technique.',
                  style: const TextStyle(color: journeyMuted)),
              JourneyField(
                  label: worker
                      ? 'Titre de mon offre de travail'
                      : 'Nom du service',
                  controller: _title),
              JourneySelect(
                  label: worker ? 'Travail proposé' : 'Catégorie',
                  value: _category,
                  values: MarketplaceCatalog.categoriesFor(_type),
                  onChanged: (v) => setState(() => _category = v)),
              JourneySelect(
                  label: 'Zone d’intervention',
                  value: _region,
                  values: MarketplaceCatalog.regions.skip(1).toList(),
                  onChanged: (v) => setState(() => _region = v)),
              JourneyField(
                  label: worker ? 'Tarif demandé en FCFA' : 'Tarif en FCFA',
                  controller: _price,
                  number: true),
              JourneySelect(
                  label: 'Tarif par',
                  value: _unit,
                  values: MarketplaceCatalog.unitsFor(_type),
                  onChanged: (v) => setState(() => _unit = v)),
              if (worker) ...[
                JourneyField(
                    label: 'Compétences et expérience',
                    controller: _experience,
                    lines: 3),
                Row(children: [
                  const Expanded(child: Text('Nombre de personnes')),
                  IconButton(
                      tooltip: 'Réduire l’équipe',
                      onPressed: _teamSize == 1
                          ? null
                          : () => setState(() => _teamSize--),
                      icon: const Icon(Icons.remove)),
                  SizedBox(
                      width: 32,
                      child: Text('$_teamSize', textAlign: TextAlign.center)),
                  IconButton(
                      tooltip: 'Agrandir l’équipe',
                      onPressed: _teamSize == 100
                          ? null
                          : () => setState(() => _teamSize++),
                      icon: const Icon(Icons.add)),
                ]),
                const Text(
                    'Le tarif indiqué s’applique à l’ensemble de l’équipe.',
                    style: TextStyle(color: journeyMuted, fontSize: 12)),
              ],
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_month_outlined),
                  title: const Text('Disponible à partir du'),
                  subtitle: Text(formatDate(_available)),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: () async {
                    final today = DateUtils.dateOnly(DateTime.now());
                    final date = await showDatePicker(
                        context: context,
                        initialDate:
                            _available.isBefore(today) ? today : _available,
                        firstDate: today,
                        lastDate: today.add(const Duration(days: 365)));
                    if (date != null && mounted) {
                      setState(() => _available = date);
                    }
                  }),
              JourneyField(
                  label: worker
                      ? 'Travaux proposés et conditions'
                      : 'Description et prestations incluses',
                  controller: _details,
                  lines: 4),
              ServicePhotoField(
                  photos: _photos,
                  required:
                      !worker && ['Tracteur', 'Matériel'].contains(_category),
                  onBusyChanged: (v) => setState(() => _photoBusy = v),
                  onChanged: (photos) => setState(() => _photos = photos)),
              const JourneyNotice(
                  'Le titre, les photos, le tarif, la région et votre nom de profil seront visibles dans le catalogue agriculteur de cet appareil.'),
              JourneyButton(
                  label: widget.serviceId == null ||
                          widget.serviceId == 'new-workforce'
                      ? 'Publier le service'
                      : 'Enregistrer les modifications',
                  icon: Icons.check,
                  onPressed: _photoBusy
                      ? null
                      : () async {
                          if (!_form.currentState!.validate()) return;
                          await store.saveService(
                              id: widget.serviceId == 'new-workforce'
                                  ? null
                                  : widget.serviceId,
                              title: _title.text,
                              category: _category,
                              region: _region,
                              price: int.parse(_price.text),
                              unit: _unit,
                              details: _details.text,
                              serviceType: _type,
                              photos: _photos,
                              experience: _experience.text,
                              teamSize: _teamSize,
                              availableFrom: _available);
                          if (context.mounted) {
                            Navigator.of(context)
                                .pushReplacementNamed('/provider-services');
                          }
                        }),
            ]));
  }
}

class ProviderRequestsPage extends StatefulWidget {
  const ProviderRequestsPage({super.key});
  static const routeName = '/provider-requests';
  @override
  State<ProviderRequestsPage> createState() => _ProviderRequestsPageState();
}

class _ProviderRequestsPageState extends State<ProviderRequestsPage> {
  String _region = MarketplaceCatalog.regions.first, _category = 'Tous';
  @override
  Widget build(BuildContext context) {
    final direct = MarketplaceScope.of(context).records(RecordKind.job).where(
        (r) =>
            r.attributes['source'] == 'direct' &&
            r.status == RecordStatus.pending);
    final requests = MarketplaceCatalog.requests
        .where((r) =>
            (_region == MarketplaceCatalog.regions.first ||
                _region == r.region) &&
            (_category == 'Tous' || _category == r.category))
        .toList();
    return JourneyScaffold(
        title: 'Travaux et demandes',
        subtitle: 'Des besoins agricoles dans votre région.',
        children: [
          if (direct.isNotEmpty) ...[
            const JourneyHeading('Demandes reçues'),
            ...direct.map((r) => RecordTile(
                record: r,
                onTap: () => openJourney(context, '/service-request-detail',
                    arguments: r.id))),
            const Divider(),
          ],
          const JourneyHeading('Besoins d’exemple'),
          JourneySelect(
              label: 'Région',
              value: _region,
              values: MarketplaceCatalog.regions,
              onChanged: (v) => setState(() => _region = v)),
          JourneySelect(
              label: 'Catégorie',
              value: _category,
              values: const [
                'Tous',
                ...MarketplaceCatalog.laborCategories,
                ...MarketplaceCatalog.serviceCategories
              ],
              onChanged: (v) => setState(() => _category = v)),
          if (requests.isEmpty)
            const JourneyEmpty(
                title: 'Aucune demande correspondante',
                message:
                    'Élargissez votre recherche à une autre région ou catégorie.'),
          ...requests.map((r) => JourneyCard(
              onTap: () => openJourney(context, '/provider-request-detail',
                  arguments: r.id),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${r.category} · ${r.region}',
                        style: const TextStyle(
                            color: journeyGreen, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(r.title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(r.client),
                    const SizedBox(height: 12),
                    Text('Budget indicatif : ${formatCfa(r.budget)}'),
                    Text('Intervention sous ${r.daysFromNow} jours'),
                  ]))),
          const JourneyNotice(
              'Demandes de démonstration. Aucun client réel ne sera contacté.'),
        ]);
  }
}

class ProviderRequestDetailPage extends StatelessWidget {
  const ProviderRequestDetailPage({required this.requestId, super.key});
  final String requestId;
  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.of(context);
    final r = MarketplaceCatalog.request(requestId);
    final quote = store
        .records(RecordKind.job)
        .where((j) =>
            j.relatedId == r.id &&
            j.status != RecordStatus.cancelled &&
            j.status != RecordStatus.declined)
        .firstOrNull;
    final services = store.records(RecordKind.service).where((s) =>
        s.attributes['category'] == r.category &&
        s.status == RecordStatus.active);
    return JourneyScaffold(
        title: r.title,
        subtitle: '${r.client} · ${r.region}',
        children: [
          JourneyCard(
              child: Text(r.description,
                  style: const TextStyle(height: 1.7, fontSize: 16))),
          JourneyCard(
              child: Text(
                  'Budget indicatif : ${formatCfa(r.budget)}\nCatégorie : ${r.category}\nIntervention souhaitée sous ${r.daysFromNow} jours',
                  style: const TextStyle(height: 2))),
          if (quote != null)
            JourneyButton(
                label: 'Voir mon devis',
                icon: Icons.description_outlined,
                onPressed: () async =>
                    openJourney(context, '/record-detail', arguments: quote.id))
          else if (services.isEmpty) ...[
            JourneyNotice(
                'Ajoutez ou réactivez un service de catégorie ${r.category} pour proposer un devis.'),
            JourneyButton(
                label: 'Gérer mes services',
                icon: Icons.agriculture_outlined,
                onPressed: () async =>
                    openJourney(context, '/provider-services')),
          ] else
            JourneyButton(
                label: 'Proposer un devis',
                icon: Icons.edit_document,
                onPressed: () async =>
                    openJourney(context, '/provider-quote', arguments: r.id)),
          JourneyButton(
              label: 'Contacter le client',
              icon: Icons.chat_outlined,
              onPressed: () => showDemoContact(context, r.client)),
        ]);
  }
}

class ProviderQuotePage extends StatefulWidget {
  const ProviderQuotePage({required this.requestId, super.key});
  final String requestId;
  @override
  State<ProviderQuotePage> createState() => _ProviderQuotePageState();
}

class _ProviderQuotePageState extends State<ProviderQuotePage> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController(), _details = TextEditingController();
  String? _serviceId;
  DateTime _date =
      DateUtils.dateOnly(DateTime.now()).add(const Duration(days: 1));
  @override
  void dispose() {
    _amount.dispose();
    _details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.of(context);
    final request = MarketplaceCatalog.request(widget.requestId);
    final services = store
        .records(RecordKind.service)
        .where((s) =>
            s.status == RecordStatus.active &&
            s.attributes['category'] == request.category)
        .toList();
    return Form(
        key: _form,
        child: JourneyScaffold(
            title: 'Proposer un devis',
            subtitle: request.title,
            children: [
              DropdownButtonFormField<String>(
                  initialValue: _serviceId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                      labelText: 'Service proposé',
                      filled: true,
                      fillColor: Colors.white),
                  items: services
                      .map((s) => DropdownMenuItem(
                          value: s.id,
                          child:
                              Text(s.title, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) => setState(() => _serviceId = v),
                  validator: (v) => v == null ? 'Choisissez un service' : null),
              JourneyField(
                  label: 'Montant total du devis en FCFA',
                  controller: _amount,
                  number: true),
              JourneyCard(
                  child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_month_outlined),
                      title: const Text('Date d’intervention'),
                      subtitle: Text(formatDate(_date)),
                      onTap: () async {
                        final now = DateUtils.dateOnly(DateTime.now());
                        final value = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: now,
                            lastDate: now.add(const Duration(days: 365)));
                        if (value != null && mounted) {
                          setState(() => _date = value);
                        }
                      })),
              JourneyField(
                  label: 'Prestations incluses et conditions',
                  controller: _details,
                  lines: 4),
              const JourneyNotice(
                  'Le devis reste en attente de l’accord du client. Il ne crée pas de mission confirmée ni de paiement.'),
              JourneyButton(
                  label: 'Enregistrer le devis',
                  icon: Icons.check,
                  onPressed: () async {
                    if (!_form.currentState!.validate()) return;
                    final result = await store.quote(
                        requestId: request.id,
                        serviceId: _serviceId!,
                        amount: int.parse(_amount.text),
                        date: _date,
                        details: _details.text);
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed(
                          '/record-detail',
                          arguments: result.id);
                    }
                  }),
            ]));
  }
}

class ProviderJobsPage extends StatefulWidget {
  const ProviderJobsPage({super.key});
  @override
  State<ProviderJobsPage> createState() => _ProviderJobsPageState();
}

class _ProviderJobsPageState extends State<ProviderJobsPage> {
  String _filter = 'Tous';
  @override
  Widget build(BuildContext context) {
    final jobs = MarketplaceScope.of(context).records(RecordKind.job);
    final visible = jobs
        .where((j) => _filter == 'Tous' || j.status.label == _filter)
        .toList();
    return JourneyScaffold(
        title: 'Mes missions',
        subtitle: 'Devis, interventions et historique.',
        root: true,
        tab: 2,
        children: [
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Tous',
                'En attente',
                'Acceptée',
                'En cours',
                'Terminée',
                'Déclinée',
                'Annulée'
              ]
                  .map((f) => ChoiceChip(
                      label: Text(f),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f)))
                  .toList()),
          if (visible.isEmpty)
            JourneyEmpty(
                title: 'Aucune mission dans cette catégorie',
                message:
                    'Répondez à une demande pour préparer votre première intervention.',
                action: JourneyButton(
                    label: 'Voir les demandes',
                    onPressed: () async =>
                        openJourney(context, '/provider-requests'))),
          ...visible.map((r) => RecordTile(
              record: r,
              onTap: () =>
                  openJourney(context, '/record-detail', arguments: r.id))),
        ]);
  }
}

class ProviderContactsPage extends StatelessWidget {
  const ProviderContactsPage({super.key});
  static const routeName = '/provider-contacts';
  @override
  Widget build(BuildContext context) {
    final jobs = MarketplaceScope.of(context).records(RecordKind.job);
    final names = jobs.map((r) => r.attributes['client']!).toSet();
    return JourneyScaffold(title: 'Mes contacts', children: [
      if (names.isEmpty)
        const JourneyEmpty(
            title: 'Aucun contact pour le moment',
            message: 'Retrouvez les clients associés à vos devis et missions.'),
      ...names.map((name) => JourneyCard(
          child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline, color: journeyGreen),
              title: Text(name),
              subtitle: Text(
                  '${jobs.where((j) => j.attributes['client'] == name).length} devis ou mission(s)'),
              trailing: const Icon(Icons.chat_outlined),
              onTap: () => showDemoContact(context, name)))),
    ]);
  }
}
