import 'package:flutter/material.dart';
import '../../../../core/data/marketplace_models.dart';
import '../../../../core/data/marketplace_store.dart';
import '../../../../core/widgets/journey_scaffold.dart';
import '../../../../core/widgets/service_photo_field.dart';
import '../../../profile_selection/domain/entities/user_profile_type.dart';

String serviceDetailRoute(BuildContext context) =>
    MarketplaceScope.of(context).role == UserProfileType.farmer
        ? '/farmer-service-detail'
        : '/provider-service-detail';

class ServiceOfferCard extends StatelessWidget {
  const ServiceOfferCard({required this.offer, super.key});
  final PublishedService offer;
  @override
  Widget build(BuildContext context) {
    final r = offer.record;
    return JourneyCard(
        padding: EdgeInsets.zero,
        onTap: () =>
            openJourney(context, serviceDetailRoute(context), arguments: r.id),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AspectRatio(
              aspectRatio: 1.9,
              child: r.photos.isNotEmpty
                  ? ColoredBox(
                      color: const Color(0xFFF5F7F9),
                      child: ServicePhoto(
                          source: r.photos.first, fit: BoxFit.contain))
                  : const ColoredBox(
                      color: Color(0xFFE7F1EC),
                      child: Center(
                          child: Icon(Icons.person_outline,
                              size: 58, color: journeyGreen)))),
          Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${offer.isDemo ? 'Exemple · ' : ''}${r.serviceType.label} · ${r.region}',
                        style:
                            const TextStyle(color: journeyMuted, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text(r.title,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: journeyInk)),
                    const SizedBox(height: 6),
                    Text(offer.providerName,
                        style: const TextStyle(color: journeyMuted)),
                    const SizedBox(height: 10),
                    Text('${formatCfa(r.amount)} / ${r.attributes['unit']}',
                        style: const TextStyle(
                            color: journeyGreen,
                            fontSize: 17,
                            fontWeight: FontWeight.w800)),
                    if (r.status == RecordStatus.paused)
                      const Text('En pause',
                          style: TextStyle(color: journeyMuted)),
                  ])),
        ]));
  }
}

class ServiceDirectoryPage extends StatefulWidget {
  const ServiceDirectoryPage({super.key});
  @override
  State<ServiceDirectoryPage> createState() => _ServiceDirectoryPageState();
}

class _ServiceDirectoryPageState extends State<ServiceDirectoryPage> {
  String _query = '', _region = MarketplaceCatalog.regions.first;
  ServiceType? _type;
  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.of(context);
    final offers = store
        .publishedServices()
        .where((o) =>
            (_type == null || o.record.serviceType == _type) &&
            (_region == MarketplaceCatalog.regions.first ||
                o.record.region == _region) &&
            '${o.record.title} ${o.record.attributes['category']} ${o.providerName}'
                .toLowerCase()
                .contains(_query.trim().toLowerCase()))
        .toList();
    return JourneyScaffold(
        title: 'Travail et matériel',
        subtitle:
            'Ouvriers agricoles et prestations près de votre exploitation.',
        children: [
          TextField(
              decoration: const InputDecoration(
                  hintText: 'Ouvrier, tracteur, prestation…',
                  prefixIcon: Icon(Icons.search)),
              onChanged: (v) => setState(() => _query = v)),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ChoiceChip(
                label: const Text('Tout'),
                selected: _type == null,
                onSelected: (_) => setState(() => _type = null)),
            for (final type in ServiceType.values)
              ChoiceChip(
                  label: Text(type.label),
                  selected: _type == type,
                  onSelected: (_) => setState(() => _type = type)),
          ]),
          JourneySelect(
              label: 'Région',
              value: _region,
              values: MarketplaceCatalog.regions,
              onChanged: (v) => setState(() => _region = v)),
          if (store.role == UserProfileType.farmer)
            OutlinedButton.icon(
                onPressed: () =>
                    openJourney(context, '/farmer-service-requests'),
                icon: const Icon(Icons.assignment_outlined),
                label: const Text('Mes demandes de prestation')),
          Text(
              '${offers.where((o) => !o.isDemo).length} offre(s) publiée(s) sur cet appareil',
              style: const TextStyle(color: journeyMuted)),
          if (offers.isEmpty)
            const JourneyEmpty(
                title: 'Aucune offre trouvée',
                message:
                    'Essayez une autre région ou un autre type de prestation.'),
          ...offers.map((o) => ServiceOfferCard(offer: o)),
          const JourneyNotice(
              'Les offres publiées sont partagées entre les profils de cet appareil. Les exemples ne peuvent pas recevoir de demande.'),
        ]);
  }
}

class ServiceGallery extends StatefulWidget {
  const ServiceGallery({required this.photos, super.key});
  final List<String> photos;
  @override
  State<ServiceGallery> createState() => _ServiceGalleryState();
}

class _ServiceGalleryState extends State<ServiceGallery> {
  int _index = 0;
  @override
  Widget build(BuildContext context) => Column(children: [
        AspectRatio(
            aspectRatio: 1.5,
            child: ColoredBox(
                color: const Color(0xFFF5F7F9),
                child: ServicePhoto(
                    source: widget
                        .photos[_index.clamp(0, widget.photos.length - 1)],
                    fit: BoxFit.contain))),
        if (widget.photos.length > 1)
          Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(spacing: 8, children: [
                for (var i = 0; i < widget.photos.length; i++)
                  Semantics(
                      button: true,
                      selected: i == _index,
                      label: 'Photo ${i + 1}',
                      child: InkWell(
                          onTap: () => setState(() => _index = i),
                          child: Container(
                              width: 68,
                              height: 56,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: i == _index
                                          ? journeyGreen
                                          : journeyBorder,
                                      width: 2)),
                              child: ServicePhoto(source: widget.photos[i])))),
              ])),
      ]);
}

class ServiceDetailPage extends StatelessWidget {
  const ServiceDetailPage({required this.serviceId, super.key});
  final String serviceId;
  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.of(context);
    final own =
        store.role == UserProfileType.provider ? store.record(serviceId) : null;
    final offer = own?.kind == RecordKind.service
        ? PublishedService(record: own!, providerName: store.name)
        : store.publishedService(serviceId);
    if (offer == null) {
      return const JourneyScaffold(title: 'Offre indisponible', children: [
        JourneyNotice('Cette offre est en pause ou n’est plus disponible.')
      ]);
    }
    final r = offer.record;
    final farmer = store.role == UserProfileType.farmer;
    final pending = store
        .records(RecordKind.job)
        .where((j) =>
            j.relatedId == r.id &&
            [RecordStatus.pending, RecordStatus.accepted, RecordStatus.active]
                .contains(j.status))
        .firstOrNull;
    return JourneyScaffold(
        title: r.serviceType.label,
        leading: r.photos.isEmpty ? null : ServiceGallery(photos: r.photos),
        bottom: own != null
            ? JourneyButton(
                label: 'Modifier mon offre',
                icon: Icons.edit_outlined,
                onPressed: () async => openJourney(
                    context, '/provider-service-form', arguments: r.id))
            : farmer && !offer.isDemo
                ? JourneyButton(
                    label: pending == null
                        ? 'Demander cette prestation'
                        : 'Suivre ma demande',
                    icon: Icons.assignment_outlined,
                    onPressed: () async => openJourney(
                        context,
                        pending == null
                            ? '/farmer-service-request'
                            : '/service-request-detail',
                        arguments: pending?.id ?? r.id))
                : null,
        children: [
          if (offer.isDemo)
            const JourneyNotice(
                'Annonce d’exemple. Le matériel et le profil présentés ne sont pas une offre réelle.'),
          Text(r.title,
              style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: journeyInk)),
          Text('${formatCfa(r.amount)} / ${r.attributes['unit']}',
              style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: journeyGreen)),
          ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline, color: journeyGreen),
              title: Text(offer.providerName),
              subtitle: Text('${r.region} · ${r.attributes['category']}')),
          const Divider(),
          JourneyHeading(r.serviceType == ServiceType.workforce
              ? 'Compétences et expérience'
              : 'Le matériel et la prestation'),
          if ((r.attributes['experience'] ?? '').isNotEmpty)
            Text(r.attributes['experience']!),
          Text(r.details, style: const TextStyle(height: 1.6)),
          if (r.serviceType == ServiceType.workforce)
            Text(
                'Équipe : ${r.attributes['teamSize'] ?? '1'} personne(s). Le tarif indiqué concerne cette équipe.'),
          if (r.attributes['availableFrom'] != null)
            Text(
                'Disponible à partir du ${formatDate(DateTime.parse(r.attributes['availableFrom']!))}'),
          if (own != null) ...[
            JourneyButton(
                label: r.status == RecordStatus.active
                    ? 'Mettre en pause'
                    : 'Réactiver mon offre',
                icon: r.status == RecordStatus.active
                    ? Icons.pause
                    : Icons.play_arrow,
                onPressed: () => store.transition(
                    r.id,
                    r.status == RecordStatus.active
                        ? RecordStatus.paused
                        : RecordStatus.active)),
            Text(
                r.status == RecordStatus.active
                    ? 'Visible dans le catalogue des agriculteurs de cet appareil.'
                    : 'Cette offre est masquée du catalogue agriculteur.',
                style: const TextStyle(color: journeyMuted)),
          ],
          if (farmer && !offer.isDemo)
            const JourneyNotice(
                'Une demande attend l’accord du prestataire. Aucun paiement n’est effectué dans l’application.'),
        ]);
  }
}

class FarmerServiceRequestForm extends StatefulWidget {
  const FarmerServiceRequestForm({required this.serviceId, super.key});
  final String serviceId;
  @override
  State<FarmerServiceRequestForm> createState() =>
      _FarmerServiceRequestFormState();
}

class _FarmerServiceRequestFormState extends State<FarmerServiceRequestForm> {
  final _form = GlobalKey<FormState>();
  final _quantity = TextEditingController(text: '1'),
      _details = TextEditingController();
  DateTime _date =
      DateUtils.dateOnly(DateTime.now()).add(const Duration(days: 1));
  bool _loaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final available = DateTime.tryParse(MarketplaceScope.of(context)
            .publishedService(widget.serviceId)
            ?.record
            .attributes['availableFrom'] ??
        '');
    if (available != null && available.isAfter(_date)) _date = available;
  }

  @override
  void dispose() {
    _quantity.dispose();
    _details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.of(context);
    final offer = store.publishedService(widget.serviceId);
    if (offer == null || offer.isDemo) {
      return const JourneyScaffold(title: 'Offre indisponible', children: [
        JourneyNotice('Choisissez une offre publiée par un prestataire.')
      ]);
    }
    final r = offer.record;
    return Form(
        key: _form,
        child: JourneyScaffold(
            title: 'Demander une prestation',
            subtitle: r.title,
            children: [
              Text('${offer.providerName} · ${r.region}',
                  style: const TextStyle(color: journeyMuted)),
              Text('${formatCfa(r.amount)} / ${r.attributes['unit']}',
                  style: const TextStyle(
                      fontSize: 22,
                      color: journeyGreen,
                      fontWeight: FontWeight.w700)),
              JourneyField(
                  label: 'Quantité (${r.attributes['unit']})',
                  controller: _quantity,
                  number: true),
              ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _quantity,
                  builder: (context, value, _) {
                    final quantity = int.tryParse(value.text.trim());
                    return Text(
                        quantity == null || quantity < 1 || quantity > 365
                            ? 'Quantité autorisée : 1 à 365'
                            : 'Total estimé : ${formatCfa(quantity * r.amount)}',
                        style: const TextStyle(fontWeight: FontWeight.w700));
                  }),
              if (r.attributes['availableFrom'] != null)
                Text(
                    'Disponible à partir du ${formatDate(DateTime.parse(r.attributes['availableFrom']!))}',
                    style: const TextStyle(color: journeyMuted)),
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_month_outlined),
                  title: const Text('Date souhaitée'),
                  subtitle: Text(formatDate(_date)),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: () async {
                    final today = DateUtils.dateOnly(DateTime.now());
                    final date = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: today,
                        lastDate: today.add(const Duration(days: 365)));
                    if (date != null && mounted) setState(() => _date = date);
                  }),
              JourneyField(
                  label: 'Lieu du champ et travail à réaliser',
                  controller: _details,
                  lines: 4),
              const JourneyNotice(
                  'Le prestataire confirmera sa disponibilité. Décrivez le travail, l’accès au champ et vos attentes.'),
              JourneyButton(
                  label: 'Envoyer ma demande',
                  icon: Icons.send_outlined,
                  onPressed: () async {
                    if (!_form.currentState!.validate()) return;
                    final request = await store.requestService(
                        serviceId: r.id,
                        quantity: int.parse(_quantity.text),
                        date: _date,
                        details: _details.text);
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed(
                          '/service-request-detail',
                          arguments: request.id);
                    }
                  }),
            ]));
  }
}

class FarmerServiceRequestsPage extends StatelessWidget {
  const FarmerServiceRequestsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final jobs = MarketplaceScope.of(context).records(RecordKind.job);
    return JourneyScaffold(title: 'Mes demandes de prestation', children: [
      if (jobs.isEmpty)
        const JourneyEmpty(
            title: 'Aucune demande',
            message:
                'Retrouvez ici vos échanges avec les ouvriers et prestataires.'),
      ...jobs.map((r) => RecordTile(
          record: r,
          onTap: () => openJourney(context, '/service-request-detail',
              arguments: r.id))),
      JourneyButton(
          label: 'Trouver un prestataire',
          icon: Icons.search,
          onPressed: () async => openJourney(context, '/farmer-services')),
    ]);
  }
}

class ServiceRequestDetailPage extends StatelessWidget {
  const ServiceRequestDetailPage({required this.requestId, super.key});
  final String requestId;
  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.of(context);
    final r = store.record(requestId);
    if (r == null ||
        r.kind != RecordKind.job ||
        r.attributes['source'] != 'direct') {
      return const JourneyScaffold(title: 'Demande introuvable', children: []);
    }
    final provider = store.role == UserProfileType.provider;
    return JourneyScaffold(
        title: 'Suivi de la prestation',
        subtitle: r.id,
        children: [
          Text(r.status.label,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: journeyGreen)),
          JourneyHeading(r.title),
          Text(
              '${provider ? 'Agriculteur' : 'Prestataire'} : ${r.attributes[provider ? 'client' : 'provider']}'),
          Text(
              '${r.region} · ${formatDate(DateTime.parse(r.attributes['date']!))}'),
          Text('${r.quantity} ${r.attributes['unit']} · ${formatCfa(r.amount)}',
              style:
                  const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
          const Divider(),
          const JourneyHeading('Travail demandé'),
          Text(r.details),
          const JourneyNotice(
              'Suivi partagé entre les deux profils sur cet appareil. Aucun règlement n’est encaissé par l’application.'),
          if (r.status == RecordStatus.pending && provider) ...[
            JourneyButton(
                label: 'Accepter la demande',
                icon: Icons.check,
                onPressed: () => store.transition(r.id, RecordStatus.accepted)),
            OutlinedButton.icon(
                onPressed: () => runJourneyAction(context,
                    () => store.transition(r.id, RecordStatus.declined)),
                icon: const Icon(Icons.close),
                label: const Text('Refuser la demande')),
          ],
          if (r.status == RecordStatus.pending && !provider)
            OutlinedButton.icon(
                onPressed: () => runJourneyAction(context,
                    () => store.transition(r.id, RecordStatus.cancelled)),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Annuler ma demande')),
          if (r.status == RecordStatus.accepted && provider)
            JourneyButton(
                label: 'Démarrer la mission',
                icon: Icons.play_arrow,
                onPressed: () => store.transition(r.id, RecordStatus.active)),
          if (r.status == RecordStatus.active && provider)
            JourneyButton(
                label: 'Terminer la mission',
                icon: Icons.check_circle_outline,
                onPressed: () =>
                    store.transition(r.id, RecordStatus.completed)),
        ]);
  }
}
