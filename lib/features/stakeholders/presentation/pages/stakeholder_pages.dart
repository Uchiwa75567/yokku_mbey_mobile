export 'investor_pages.dart';
export 'provider_pages.dart';

import 'package:flutter/material.dart';
import '../../../../core/data/marketplace_models.dart';
import '../../../../core/data/marketplace_store.dart';
import '../../../../core/widgets/journey_scaffold.dart';
import '../../../profile_selection/domain/entities/user_profile_type.dart';
import 'investor_pages.dart';
import 'service_directory_pages.dart';

class StakeholderHomePage extends StatelessWidget {
  const StakeholderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.of(context);
    final investor = store.role == UserProfileType.investor;
    final records =
        store.records(investor ? RecordKind.investment : RecordKind.job);
    final offers = store.records(RecordKind.service);
    final pending =
        records.where((r) => r.status == RecordStatus.pending).length;
    return JourneyScaffold(
      title: investor ? 'Bonjour partenaire' : 'Bonjour prestataire',
      root: true,
      homeHeader: true,
      children: [
        Text(
            store.name == 'Mon compte'
                ? (investor ? 'Bonjour partenaire' : 'Bonjour prestataire')
                : 'Bonjour, ${store.name}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        Text(
            investor
                ? 'Les projets de nos territoires'
                : 'Mon travail, mon activité',
            style: const TextStyle(color: journeyMuted)),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: _Metric(
                  value: investor
                      ? '$pending'
                      : '${offers.where((r) => r.status == RecordStatus.active).length}',
                  label:
                      investor ? 'Intentions en attente' : 'Offres en ligne')),
          const SizedBox(width: 20),
          Expanded(
              child: _Metric(
                  value: investor
                      ? '${MarketplaceCatalog.projects.length}'
                      : '$pending',
                  label: investor
                      ? 'Projets à découvrir'
                      : 'Demandes et devis en attente',
                  color: const Color(0xFF256F95))),
        ]),
        const Divider(),
        if (investor) ...[
          JourneyButton(
              label: 'Voir les projets',
              icon: Icons.search,
              onPressed: () async =>
                  openJourney(context, '/investor-projects')),
          const JourneyHeading('Projet à la une'),
          ProjectCard(project: MarketplaceCatalog.projects.first),
          const _Shortcut(
              icon: Icons.handshake_outlined,
              title: 'Mes intentions',
              subtitle: 'Montants proposés et suivi',
              route: '/investor-funding'),
          const _Shortcut(
              icon: Icons.insights_outlined,
              title: 'Suivre les impacts',
              subtitle: 'Objectifs des projets suivis',
              route: '/investor-impact'),
          const JourneyNotice(
              'Projets d’exemple. Les intentions ne déclenchent aucun paiement.'),
        ] else ...[
          JourneyButton(
              label: 'Ajouter un service',
              icon: Icons.add,
              onPressed: () async =>
                  openJourney(context, '/provider-service-form')),
          const _Shortcut(
              icon: Icons.assignment_outlined,
              title: 'Voir les demandes',
              subtitle: 'Travaux agricoles et besoins en matériel',
              route: '/provider-requests'),
          if (records.isNotEmpty) ...[
            const JourneyHeading('À suivre'),
            ...records.take(2).map((r) => RecordTile(
                record: r,
                onTap: () =>
                    openJourney(context, '/record-detail', arguments: r.id))),
          ],
          JourneyHeading(
              offers.isEmpty ? 'Travail et matériel' : 'Mes dernières offres'),
          if (offers.isNotEmpty)
            ...offers.take(2).map((r) => ServiceOfferCard(
                offer: PublishedService(record: r, providerName: store.name)))
          else ...[
            ServiceOfferCard(offer: MarketplaceCatalog.serviceExamples.first),
            const _Shortcut(
                icon: Icons.person_outline,
                title: 'Travailler dans les champs',
                subtitle: 'Récolte, semis, désherbage et préparation du sol',
                route: '/provider-service-form',
                arguments: 'new-workforce'),
          ],
          const _Shortcut(
              icon: Icons.storefront_outlined,
              title: 'Catalogue des prestataires',
              subtitle: 'Les offres visibles côté agriculteur',
              route: '/provider-directory'),
          const _Shortcut(
              icon: Icons.people_outline,
              title: 'Gérer mes contacts',
              subtitle: 'Les agriculteurs de mes missions',
              route: '/provider-contacts'),
        ],
      ],
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.route,
      this.arguments});
  final IconData icon;
  final String title, subtitle, route;
  final Object? arguments;
  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: journeyGreen),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: () => openJourney(context, route, arguments: arguments),
      );
}

class _Metric extends StatelessWidget {
  const _Metric(
      {required this.value, required this.label, this.color = journeyGreen});
  final String value, label;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12, color: journeyMuted)),
      ]);
}
