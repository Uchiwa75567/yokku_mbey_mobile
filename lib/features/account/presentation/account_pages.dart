import 'package:flutter/material.dart';
import '../../stakeholders/presentation/pages/service_directory_pages.dart';
import '../../../core/data/marketplace_models.dart';
import '../../../core/data/marketplace_store.dart';
import '../../../core/widgets/journey_scaffold.dart';
import '../../profile_selection/domain/entities/user_profile_type.dart';

Future<void> showDemoContact(BuildContext context, String name) =>
    showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (ctx) => SafeArea(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      const Text(
                          'Ce contact appartient au catalogue de démonstration. Aucun numéro réel n’est associé à ce profil.',
                          style: TextStyle(height: 1.5)),
                      const SizedBox(height: 16),
                      const ListTile(
                          leading: Icon(Icons.call_outlined),
                          title: Text('Appel indisponible')),
                      const ListTile(
                          leading: Icon(Icons.chat_outlined),
                          title: Text('WhatsApp indisponible')),
                      FilledButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Fermer')),
                    ]))));

class AccountProfilePage extends StatelessWidget {
  const AccountProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.of(context);
    final buyer = store.role == UserProfileType.buyer;
    final investor = store.role == UserProfileType.investor;
    final links = <(IconData, String, String)>[
      (Icons.swap_horiz_rounded, 'Changer d’espace', '/profile-selection'),
      (Icons.badge_outlined, 'Informations personnelles', '/account-personal'),
      if (buyer) ...[
        (Icons.shopping_basket_outlined, 'Mes achats', '/buyer-purchases'),
        (Icons.assignment_outlined, 'Mes demandes', '/buyer-needs'),
        (Icons.favorite_border, 'Favoris et alertes', '/buyer-favorites'),
        (
          Icons.location_on_outlined,
          'Adresses de livraison',
          '/buyer-delivery-addresses'
        ),
        (
          Icons.account_balance_wallet_outlined,
          'Paiements',
          '/buyer-payment-history'
        ),
        (Icons.star_outline, 'Mes avis', '/buyer-reputation'),
      ] else if (investor) ...[
        (Icons.eco_outlined, 'Mes financements', '/investor-funding'),
        (Icons.insights_outlined, 'Suivre les impacts', '/investor-impact'),
      ] else ...[
        (Icons.agriculture_outlined, 'Mes services', '/provider-services'),
        (Icons.assignment_outlined, 'Mes missions', '/provider-jobs'),
        (Icons.people_outline, 'Mes contacts', '/provider-contacts'),
      ],
      (Icons.settings_outlined, 'Paramètres', '/account-settings'),
      (Icons.help_outline, 'Aide et support', '/account-help'),
    ];
    return JourneyScaffold(
        title: 'Mon profil',
        subtitle: '${store.name}\n${store.role?.label} · ${store.phone}',
        root: true,
        tab: 3,
        children: [
          ...links.map((item) => JourneyCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                  leading: Icon(item.$1, color: journeyGreen),
                  title: Text(item.$2),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => openJourney(context, item.$3)))),
          JourneyButton(
              label: 'Se déconnecter',
              icon: Icons.logout_rounded,
              onPressed: () => logout(context)),
          const JourneyNotice(
              'Mode démonstration. Les données de ce compte sont enregistrées sur cet appareil.'),
        ]);
  }
}

enum AccountFormKind { personal, address, alert, support, review }

class AccountFormPage extends StatefulWidget {
  const AccountFormPage({required this.kind, this.recordId, super.key});
  final AccountFormKind kind;
  final String? recordId;
  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController(),
      _details = TextEditingController(),
      _amount = TextEditingController();
  String _region = 'Dakar';
  int _stars = 0;
  bool _loaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final store = MarketplaceScope.of(context);
    if (widget.kind == AccountFormKind.personal) {
      _title.text = store.profile['name'] ?? '';
      _region = store.profile['region'] ?? 'Dakar';
      _details.text = store.profile['organization'] ?? '';
    } else if (widget.kind == AccountFormKind.address &&
        widget.recordId != null) {
      final old = store.record(widget.recordId!);
      if (old != null) {
        _title.text = old.title;
        _details.text = old.details;
        _region = old.region;
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.of(context);
    final kind = widget.kind;
    final title = switch (kind) {
      AccountFormKind.personal => 'Informations personnelles',
      AccountFormKind.address =>
        widget.recordId == null ? 'Ajouter une adresse' : 'Modifier l’adresse',
      AccountFormKind.alert => 'Créer une alerte',
      AccountFormKind.support => 'Signaler un problème',
      AccountFormKind.review => 'Noter mon achat',
    };
    return Form(
        key: _form,
        child: JourneyScaffold(title: title, children: [
          if (kind == AccountFormKind.personal)
            JourneyCard(child: Text('Numéro du compte : ${store.phone}')),
          if (kind != AccountFormKind.review)
            JourneyField(
                label: switch (kind) {
                  AccountFormKind.personal => 'Nom complet',
                  AccountFormKind.address => 'Nom de l’adresse',
                  AccountFormKind.alert => 'Produit recherché',
                  _ => 'Objet du problème',
                },
                controller: _title),
          if (kind != AccountFormKind.support && kind != AccountFormKind.review)
            JourneySelect(
                label: 'Région',
                value: _region,
                values: MarketplaceCatalog.regions.skip(1).toList(),
                onChanged: (v) => setState(() => _region = v)),
          if (kind == AccountFormKind.alert)
            JourneyField(
                label: 'Prix maximal par kg en FCFA',
                controller: _amount,
                number: true),
          if (kind == AccountFormKind.review)
            JourneyCard(
                child: Wrap(
                    alignment: WrapAlignment.center,
                    children: List.generate(
                        5,
                        (i) => IconButton(
                            tooltip: '${i + 1} étoile${i > 0 ? 's' : ''}',
                            onPressed: () => setState(() => _stars = i + 1),
                            icon: Icon(
                                i < _stars ? Icons.star : Icons.star_border,
                                color: const Color(0xFFAC7400),
                                size: 30))))),
          if (kind != AccountFormKind.alert)
            JourneyField(
                label: switch (kind) {
                  AccountFormKind.personal => 'Organisation (facultatif)',
                  AccountFormKind.address => 'Quartier, rue et indications',
                  AccountFormKind.review => 'Votre avis (facultatif)',
                  _ => 'Description du problème',
                },
                controller: _details,
                lines: kind == AccountFormKind.personal ? 1 : 3,
                required: kind != AccountFormKind.personal &&
                    kind != AccountFormKind.review),
          if (kind == AccountFormKind.support)
            const JourneyNotice(
                'Le signalement sera conservé localement. L’envoi à une équipe de support nécessite la connexion au service.'),
          if (kind == AccountFormKind.alert)
            const JourneyNotice(
                'Les correspondances apparaîtront dans vos alertes. Les notifications à distance ne sont pas encore connectées.'),
          JourneyButton(
              label: 'Enregistrer',
              icon: Icons.check_rounded,
              onPressed: () async {
                if (!_form.currentState!.validate()) return;
                switch (kind) {
                  case AccountFormKind.personal:
                    await store.saveProfile({
                      'name': _title.text,
                      'region': _region,
                      'organization': _details.text
                    });
                  case AccountFormKind.address:
                    await store.saveAddress(
                        id: widget.recordId,
                        name: _title.text,
                        region: _region,
                        details: _details.text);
                  case AccountFormKind.alert:
                    await store.saveAlert(
                        product: _title.text,
                        region: _region,
                        maxPrice: int.parse(_amount.text));
                  case AccountFormKind.support:
                    await store.report(
                        title: _title.text,
                        details: _details.text,
                        orderId: widget.recordId ?? '');
                  case AccountFormKind.review:
                    await store.review(
                        orderId: widget.recordId ?? '',
                        stars: _stars,
                        details: _details.text);
                }
                if (context.mounted) Navigator.of(context).pop();
              }),
        ]));
  }
}

class AccountListPage extends StatelessWidget {
  const AccountListPage({required this.kind, super.key});
  final RecordKind kind;
  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.of(context);
    final records = store.records(kind);
    final title = switch (kind) {
      RecordKind.address => 'Adresses de livraison',
      RecordKind.alert => 'Mes alertes',
      RecordKind.review => 'Mes avis',
      _ => 'Mes signalements'
    };
    return JourneyScaffold(title: title, children: [
      if (kind == RecordKind.address || kind == RecordKind.alert)
        JourneyButton(
            label: kind == RecordKind.address
                ? 'Ajouter une adresse'
                : 'Créer une alerte',
            icon: Icons.add,
            onPressed: () async => openJourney(
                context,
                kind == RecordKind.address
                    ? '/buyer-address-form'
                    : '/buyer-create-alert')),
      if (records.isEmpty)
        const JourneyEmpty(
            title: 'Aucun élément enregistré',
            message: 'Les éléments de votre compte apparaîtront ici.'),
      ...records.map((r) => JourneyCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(r.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(kind == RecordKind.review
                    ? '${r.quantity}/5 · ${r.details}'
                    : '${r.region}${r.region.isEmpty ? '' : '\n'}${r.details}'),
                if (kind == RecordKind.alert) ...[
                  Text('Prix maximal : ${formatCfa(r.amount)} / kg'),
                  Text(
                      '${r.status.label} · ${MarketplaceCatalog.products.where((p) => p.name.toLowerCase().contains(r.title.toLowerCase()) && p.region == r.region && p.unitPrice <= r.amount).length} correspondance(s)'),
                  TextButton(
                      onPressed: () => runJourneyAction(
                          context,
                          () => store.transition(
                              r.id,
                              r.status == RecordStatus.active
                                  ? RecordStatus.paused
                                  : RecordStatus.active)),
                      child: Text(r.status == RecordStatus.active
                          ? 'Mettre en pause'
                          : 'Réactiver')),
                ],
                if (kind == RecordKind.address)
                  Row(children: [
                    IconButton(
                        tooltip: 'Modifier l’adresse',
                        onPressed: () => openJourney(
                            context, '/buyer-address-form',
                            arguments: r.id),
                        icon: const Icon(Icons.edit_outlined)),
                    IconButton(
                        tooltip: 'Supprimer l’adresse',
                        onPressed: () => runJourneyAction(
                            context, () => store.removeAddress(r.id)),
                        icon: const Icon(Icons.delete_outline)),
                  ]),
                if (kind == RecordKind.issue) ...[
                  const SizedBox(height: 8),
                  const Text('Enregistré localement · non transmis')
                ],
              ]))),
    ]);
  }
}

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.of(context);
    return JourneyScaffold(title: 'Paramètres', children: [
      JourneyCard(
          child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Alertes de disponibilité'),
              subtitle: const Text(
                  'Afficher les correspondances dans mes notifications'),
              value: store.profile['alerts'] != 'false',
              onChanged: (v) => runJourneyAction(
                  context,
                  () => store
                      .saveProfile({'name': store.name, 'alerts': '$v'})))),
      JourneyCard(
          child: Text(
              'Langue : Français\nDevise : FCFA\nProfil : ${store.role?.label}',
              style: const TextStyle(height: 2))),
      JourneyButton(
          label: 'Se déconnecter',
          icon: Icons.logout,
          onPressed: () => logout(context)),
    ]);
  }
}

class AccountNotificationsPage extends StatelessWidget {
  const AccountNotificationsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.of(context);
    final items = [
      for (final kind in [
        RecordKind.order,
        RecordKind.investment,
        RecordKind.job,
        RecordKind.need
      ])
        ...store.records(kind)
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final matches = store.profile['alerts'] == 'false'
        ? <ProductListing>[]
        : MarketplaceCatalog.products
            .where((p) => store.records(RecordKind.alert).any((a) =>
                a.status == RecordStatus.active &&
                p.name.toLowerCase().contains(a.title.toLowerCase()) &&
                a.region == p.region &&
                p.unitPrice <= a.amount))
            .toList();
    return JourneyScaffold(title: 'Notifications', children: [
      if (items.isEmpty && matches.isEmpty)
        const JourneyEmpty(
            title: 'Vous êtes à jour',
            message: 'Vos réservations, demandes et alertes apparaîtront ici.'),
      ...matches.map((p) => JourneyCard(
          child: ListTile(
              title: Text('Une offre correspond à votre alerte : ${p.name}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => openJourney(context, '/buyer-product-detail',
                  arguments: p.id)))),
      ...items.map((r) => RecordTile(
          record: r,
          onTap: () =>
              openJourney(context, '/record-detail', arguments: r.id))),
    ]);
  }
}

class AccountHelpPage extends StatelessWidget {
  const AccountHelpPage({super.key});
  @override
  Widget build(BuildContext context) =>
      JourneyScaffold(title: 'Aide et support', children: [
        ...const [
          (
            'Comment fonctionne une réservation ?',
            'Elle reste en attente jusqu’à la confirmation du producteur. Vérifiez la quantité, le prix et le lieu de réception avant tout règlement.'
          ),
          (
            'Quand mon financement est-il confirmé ?',
            'Une intention exprime votre intérêt. Le porteur de projet doit accepter les conditions. Aucune somme n’est transférée dans cette version.'
          ),
          (
            'Comment suivre une prestation ?',
            'Un devis attend l’accord du client. Une mission acceptée peut ensuite être démarrée et terminée par le prestataire.'
          ),
        ].map((faq) => JourneyCard(
            padding: EdgeInsets.zero,
            child: ExpansionTile(title: Text(faq.$1), children: [
              Padding(padding: const EdgeInsets.all(16), child: Text(faq.$2))
            ]))),
        JourneyButton(
            label: 'Signaler un problème',
            icon: Icons.flag_outlined,
            onPressed: () async => openJourney(context, '/account-report')),
        JourneyButton(
            label: 'Mes signalements',
            icon: Icons.inbox_outlined,
            onPressed: () async => openJourney(context, '/account-issues')),
      ]);
}

class AccountPaymentsPage extends StatelessWidget {
  const AccountPaymentsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final orders = MarketplaceScope.of(context)
        .records(RecordKind.order)
        .where((r) => r.status != RecordStatus.cancelled)
        .toList();
    return JourneyScaffold(title: 'Paiements', children: [
      const JourneyNotice(
          'Aucun paiement en ligne n’est connecté. Aucun prélèvement ni remboursement n’a été effectué par l’application.'),
      const JourneyHeading('Montants des réservations'),
      if (orders.isEmpty)
        const JourneyEmpty(
            title: 'Aucune réservation à régler',
            message: 'Les montants seront affichés après une réservation.'),
      ...orders.map((r) => RecordTile(
          record: r,
          onTap: () =>
              openJourney(context, '/buyer-order-tracking', arguments: r.id))),
    ]);
  }
}

class RecordDetailsPage extends StatelessWidget {
  const RecordDetailsPage({required this.recordId, super.key});
  final String recordId;

  Future<void> _change(BuildContext context, MarketplaceStore store,
      MarketRecord r, RecordStatus next) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('Confirmer le changement'),
                content: Text('${r.title}\nNouveau statut : ${next.label}'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Retour')),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Confirmer')),
                ]));
    if (confirmed == true) await store.transition(r.id, next);
  }

  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.of(context);
    final r = store.record(recordId);
    if (r == null) {
      return const JourneyScaffold(title: 'Élément introuvable', children: [
        JourneyNotice(
            'Cet élément n’appartient pas à votre compte ou n’est plus disponible.')
      ]);
    }
    if (r.kind == RecordKind.job && r.attributes['source'] == 'direct') {
      return ServiceRequestDetailPage(requestId: r.id);
    }
    if (r.kind == RecordKind.service) return ServiceDetailPage(serviceId: r.id);
    final order = r.kind == RecordKind.order,
        need = r.kind == RecordKind.need,
        investment = r.kind == RecordKind.investment,
        job = r.kind == RecordKind.job,
        service = r.kind == RecordKind.service;
    final canCancel =
        (order || investment || job) && r.status == RecordStatus.pending;
    final contact = r.attributes['producer'] ??
        r.attributes['owner'] ??
        r.attributes['client'];
    return JourneyScaffold(
        title: r.title,
        subtitle: r.id,
        leading: investment
            ? AspectRatio(
                aspectRatio: 1.8,
                child: Image.asset(
                    MarketplaceCatalog.project(r.relatedId).image,
                    fit: BoxFit.cover))
            : null,
        children: [
          if (investment)
            const JourneyNotice(
                'Intention locale, sans contrat ni paiement. Montant transféré : 0 FCFA.'),
          JourneyCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(r.status.label,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: journeyGreen)),
                const SizedBox(height: 14),
                Text('Enregistré le ${formatDate(r.createdAt)}'),
                if (r.region.isNotEmpty) Text(r.region),
                if (r.quantity > 0)
                  Text('${r.quantity} ${r.attributes['unit'] ?? 'kg'}'),
                if (r.amount > 0)
                  Text(
                      '${need ? 'Budget : ' : ''}${formatCfa(r.amount)}${service ? ' / ${r.attributes['unit']}' : ''}',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w700)),
                if (r.details.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(r.details)
                ],
                if (r.attributes['date'] != null) ...[
                  const SizedBox(height: 10),
                  Text(
                      'Date souhaitée : ${formatDate(DateTime.parse(r.attributes['date']!))}')
                ],
                if (order) ...[
                  const SizedBox(height: 10),
                  Text('Réception : ${r.attributes['recovery']}'),
                  if ((r.attributes['address'] ?? '').isNotEmpty)
                    Text(r.attributes['address']!),
                  Text('Règlement : ${r.attributes['payment']}')
                ],
              ])),
          if (order || investment || job) ...[
            const JourneyHeading('Suivi'),
            JourneyCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.check_circle, color: journeyGreen),
                      title: Text('Demande enregistrée')),
                  ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                          r.status == RecordStatus.pending
                              ? Icons.schedule
                              : Icons.info_outline,
                          color: journeyGreen),
                      title: Text(r.status == RecordStatus.pending
                          ? (job
                              ? 'En attente de l’accord du client'
                              : investment
                                  ? 'En attente du porteur de projet'
                                  : 'En attente du producteur')
                          : r.status.label)),
                ])),
            if (r.status == RecordStatus.pending)
              const JourneyNotice(
                  'Cette demande est enregistrée en démonstration. Sa transmission et les réponses nécessitent la connexion au service.'),
          ],
          if (contact != null)
            JourneyButton(
                label: 'Contacter $contact',
                icon: Icons.chat_outlined,
                onPressed: () => showDemoContact(context, contact)),
          if (investment)
            OutlinedButton.icon(
                onPressed: () => openJourney(
                    context, '/investor-project-detail',
                    arguments: r.relatedId),
                icon: const Icon(Icons.eco_outlined),
                label: const Text('Revoir le projet')),
          if (need && r.status == RecordStatus.active) ...[
            JourneyButton(
                label: 'Modifier ma demande',
                icon: Icons.edit_outlined,
                onPressed: () async => openJourney(
                    context, '/publish-buyer-need',
                    arguments: r.id)),
            JourneyButton(
                label: 'Voir les offres correspondantes',
                icon: Icons.storefront_outlined,
                onPressed: () async =>
                    openJourney(context, '/buyer-proposals', arguments: r.id)),
            JourneyButton(
                label: 'Clôturer la demande',
                icon: Icons.check_circle_outline,
                onPressed: () =>
                    _change(context, store, r, RecordStatus.closed)),
          ],
          if (service) ...[
            JourneyButton(
                label: 'Modifier le service',
                icon: Icons.edit_outlined,
                onPressed: () async => openJourney(
                    context, '/provider-service-form',
                    arguments: r.id)),
            JourneyButton(
                label: r.status == RecordStatus.active
                    ? 'Mettre en pause'
                    : 'Réactiver le service',
                icon: Icons.pause_circle_outline,
                onPressed: () => store.transition(
                    r.id,
                    r.status == RecordStatus.active
                        ? RecordStatus.paused
                        : RecordStatus.active)),
          ],
          if (job && r.status == RecordStatus.accepted)
            JourneyButton(
                label: 'Démarrer la mission',
                icon: Icons.play_arrow,
                onPressed: () =>
                    _change(context, store, r, RecordStatus.active)),
          if ((job || order) && r.status == RecordStatus.active)
            JourneyButton(
                label: job ? 'Terminer la mission' : 'Confirmer la réception',
                icon: Icons.check,
                onPressed: () =>
                    _change(context, store, r, RecordStatus.completed)),
          if (order &&
              r.status == RecordStatus.completed &&
              !store
                  .records(RecordKind.review)
                  .any((review) => review.relatedId == r.id))
            JourneyButton(
                label: 'Noter cet achat',
                icon: Icons.star_outline,
                onPressed: () async => openJourney(
                    context, '/buyer-rate-transaction',
                    arguments: r.id)),
          if (canCancel)
            JourneyButton(
                label: order
                    ? 'Annuler la réservation'
                    : job
                        ? 'Retirer le devis'
                        : 'Retirer mon intention',
                icon: Icons.cancel_outlined,
                onPressed: () =>
                    _change(context, store, r, RecordStatus.cancelled)),
          if (order)
            JourneyButton(
                label: 'Signaler un problème',
                icon: Icons.flag_outlined,
                onPressed: () async => openJourney(
                    context, '/buyer-report-problem',
                    arguments: r.id)),
        ]);
  }
}
