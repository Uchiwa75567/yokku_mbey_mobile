import 'package:flutter/material.dart';
import '../../../../core/data/marketplace_models.dart';
import '../../../../core/data/marketplace_store.dart';
import '../../../../core/widgets/journey_scaffold.dart';
import '../../../account/presentation/account_pages.dart';

class InvestorProjectsPage extends StatefulWidget {
  const InvestorProjectsPage({super.key});
  static const routeName = '/investor-projects';
  @override
  State<InvestorProjectsPage> createState() => _InvestorProjectsPageState();
}

class _InvestorProjectsPageState extends State<InvestorProjectsPage> {
  String _query = '',
      _region = MarketplaceCatalog.regions.first,
      _category = 'Tous';
  @override
  Widget build(BuildContext context) {
    final projects = MarketplaceCatalog.projects
        .where((p) =>
            '${p.name} ${p.owner}'
                .toLowerCase()
                .contains(_query.trim().toLowerCase()) &&
            (_region == MarketplaceCatalog.regions.first ||
                p.region == _region) &&
            (_category == 'Tous' || p.category == _category))
        .toList();
    return JourneyScaffold(
        title: 'Projets agricoles',
        subtitle: 'Rencontrez les porteurs de projets locaux.',
        root: true,
        tab: 1,
        children: [
          TextField(
              decoration: const InputDecoration(
                  hintText: 'Rechercher un projet',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder()),
              onChanged: (v) => setState(() => _query = v)),
          JourneySelect(
              label: 'Région',
              value: _region,
              values: MarketplaceCatalog.regions,
              onChanged: (v) => setState(() => _region = v)),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Tous', 'Irrigation', 'Équipement', 'Semences']
                  .map((c) => ChoiceChip(
                      label: Text(c),
                      selected: c == _category,
                      onSelected: (_) => setState(() => _category = c)))
                  .toList()),
          const JourneyNotice(
              'Projets de démonstration. Les montants présentés ne constituent pas une collecte réelle.'),
          if (projects.isEmpty)
            const JourneyEmpty(
                title: 'Aucun projet trouvé',
                message: 'Essayez une autre région ou une autre catégorie.'),
          ...projects.map((p) => ProjectCard(project: p)),
        ]);
  }
}

class ProjectCard extends StatelessWidget {
  const ProjectCard({required this.project, super.key});
  final ProjectListing project;
  @override
  Widget build(BuildContext context) => JourneyCard(
      padding: EdgeInsets.zero,
      onTap: () => openJourney(context, '/investor-project-detail',
          arguments: project.id),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: AspectRatio(
                aspectRatio: 1.8,
                child: Image.asset(project.image, fit: BoxFit.cover))),
        Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Exemple · ${project.category} · ${project.region}',
                  style: const TextStyle(
                      color: journeyGreen, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(project.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(project.owner),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                  value: project.raised / project.target,
                  minHeight: 6,
                  color: journeyGreen,
                  backgroundColor: const Color(0xFFE0E8E2)),
              const SizedBox(height: 8),
              Text(
                  '${formatCfa(project.raised)} / ${formatCfa(project.target)}'),
              const SizedBox(height: 8),
              Text('À partir de ${formatCfa(project.minimum)}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                  '${project.durationMonths} mois · ${project.beneficiaries} bénéficiaires visés',
                  style: const TextStyle(color: journeyMuted, fontSize: 12)),
            ])),
      ]));
}

class InvestorProjectDetailPage extends StatelessWidget {
  const InvestorProjectDetailPage({required this.projectId, super.key});
  final String projectId;
  @override
  Widget build(BuildContext context) {
    final p =
        MarketplaceCatalog.projects.where((p) => p.id == projectId).firstOrNull;
    if (p == null) {
      return const JourneyScaffold(title: 'Projet introuvable', children: []);
    }
    final open = MarketplaceScope.of(context)
        .records(RecordKind.investment)
        .where((r) =>
            r.relatedId == projectId && r.status != RecordStatus.cancelled)
        .firstOrNull;
    return JourneyScaffold(
      title: 'Le projet',
      leading: AspectRatio(
          aspectRatio: 1.7, child: Image.asset(p.image, fit: BoxFit.cover)),
      bottom: JourneyButton(
          label: open == null ? 'Soutenir ce projet' : 'Voir mon intention',
          icon: Icons.handshake_outlined,
          onPressed: () async => openJourney(
              context, open == null ? '/investor-commitment' : '/record-detail',
              arguments: open?.id ?? p.id)),
      children: [
        Text('Projet d’exemple · ${p.category} · ${p.region}',
            style: const TextStyle(color: journeyMuted, fontSize: 12)),
        Text(p.name,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
        ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.groups_outlined, color: journeyGreen),
            title: Text(p.owner),
            subtitle: Text(p.region)),
        Text(p.description, style: const TextStyle(fontSize: 16, height: 1.6)),
        const Divider(),
        const JourneyHeading('Objectif de financement'),
        Text(formatCfa(p.target),
            style: const TextStyle(
                fontSize: 27,
                color: journeyGreen,
                fontWeight: FontWeight.w800)),
        LinearProgressIndicator(
            value: p.raised / p.target,
            minHeight: 7,
            color: journeyGreen,
            backgroundColor: const Color(0xFFE5ECE8)),
        Text(
            '${formatCfa(p.raised)} présentés dans ce scénario · ${(100 * p.raised / p.target).round()} %',
            style: const TextStyle(color: journeyMuted)),
        Wrap(spacing: 28, runSpacing: 16, children: [
          _ProjectFact(
              icon: Icons.schedule_outlined,
              value: '${p.durationMonths} mois',
              label: 'Durée indicative'),
          _ProjectFact(
              icon: Icons.people_outline,
              value: '${p.beneficiaries}',
              label: 'Bénéficiaires visés'),
          _ProjectFact(
              icon: Icons.handshake_outlined,
              value: formatCfa(p.minimum),
              label: 'Intention minimale'),
        ]),
        const Divider(),
        const JourneyHeading('Utilisation prévue des fonds'),
        ...p.useOfFunds.split('\n').map((line) =>
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.check_circle_outline,
                  size: 20, color: journeyGreen),
              const SizedBox(width: 12),
              Expanded(child: Text(line)),
            ])),
        const JourneyHeading('Étapes prévisionnelles'),
        const _ProjectStage(
            number: '01',
            title: 'Accord et budget',
            detail:
                'Conditions, justificatifs et budget à valider avec le porteur.'),
        const _ProjectStage(
            number: '02',
            title: 'Mise en place',
            detail: 'Acquisition, installation et accompagnement prévus.'),
        const _ProjectStage(
            number: '03',
            title: 'Bilan de campagne',
            detail:
                'Résultats attendus à comparer aux réalisations documentées.'),
        const JourneyNotice(
            'Projet de démonstration, sans collecte réelle. Aucun rendement garanti. Les objectifs ne sont pas des résultats réalisés.'),
        OutlinedButton.icon(
            onPressed: () => showDemoContact(context, p.owner),
            icon: const Icon(Icons.chat_outlined),
            label: const Text('Contacter le porteur du projet')),
      ],
    );
  }
}

class _ProjectFact extends StatelessWidget {
  const _ProjectFact(
      {required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value, label;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: const Color(0xFF256F95), size: 21),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(fontSize: 12, color: journeyMuted)),
      ]);
}

class _ProjectStage extends StatelessWidget {
  const _ProjectStage(
      {required this.number, required this.title, required this.detail});
  final String number, title, detail;
  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 38,
            child: Text(number,
                style: const TextStyle(
                    color: journeyGreen, fontWeight: FontWeight.w700))),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(detail,
              style: const TextStyle(color: journeyMuted, height: 1.5)),
        ])),
      ]);
}

class InvestorCommitmentPage extends StatefulWidget {
  const InvestorCommitmentPage({required this.projectId, super.key});
  final String projectId;
  @override
  State<InvestorCommitmentPage> createState() => _InvestorCommitmentPageState();
}

class _InvestorCommitmentPageState extends State<InvestorCommitmentPage> {
  final _form = GlobalKey<FormState>();
  late final _amount = TextEditingController(
      text: '${MarketplaceCatalog.project(widget.projectId).minimum}');
  final _message = TextEditingController();
  bool _consent = false;
  @override
  void dispose() {
    _amount.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.of(context);
    final p = MarketplaceCatalog.project(widget.projectId);
    return Form(
        key: _form,
        child: JourneyScaffold(
            title: 'Mon intention de financement',
            subtitle: p.name,
            children: [
              AspectRatio(
                  aspectRatio: 2,
                  child: Image.asset(p.image, fit: BoxFit.cover)),
              Text(
                  'Entre ${formatCfa(p.minimum)} et ${formatCfa(p.remaining)}\nPorteur : ${p.owner}',
                  style: const TextStyle(height: 1.8)),
              TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Montant en FCFA'),
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final amount = int.tryParse(value?.trim() ?? '');
                    if (amount == null ||
                        amount < p.minimum ||
                        amount > p.remaining) {
                      return 'Entre ${formatCfa(p.minimum)} et ${formatCfa(p.remaining)}';
                    }
                    return null;
                  }),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final amount in {p.minimum, p.minimum * 2, p.minimum * 5}
                    .where((v) => v <= p.remaining))
                  OutlinedButton(
                      onPressed: () => setState(() => _amount.text = '$amount'),
                      child: Text(formatCfa(amount))),
              ]),
              JourneyField(
                  label: 'Message au porteur (facultatif)',
                  controller: _message,
                  lines: 3,
                  required: false),
              const JourneyNotice(
                  'Cette intention ne vaut ni contrat ni paiement. Aucun montant ne sera prélevé.'),
              CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _consent,
                  onChanged: (v) => setState(() => _consent = v ?? false),
                  title: const Text(
                      'J’ai consulté le projet et comprends que les conditions restent à valider.',
                      style: TextStyle(color: journeyInk))),
              JourneyButton(
                  label: 'Enregistrer mon intention',
                  icon: Icons.check,
                  onPressed: () async {
                    if (!_form.currentState!.validate()) return;
                    final result = await store.invest(
                        projectId: p.id,
                        amount: int.parse(_amount.text.trim()),
                        message: _message.text,
                        consent: _consent);
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed(
                          '/record-detail',
                          arguments: result.id);
                    }
                  }),
            ]));
  }
}

class InvestorFundingPage extends StatefulWidget {
  const InvestorFundingPage({super.key});
  static const routeName = '/investor-funding';
  @override
  State<InvestorFundingPage> createState() => _InvestorFundingPageState();
}

class _InvestorFundingPageState extends State<InvestorFundingPage> {
  RecordStatus? _status;
  @override
  Widget build(BuildContext context) {
    final items = MarketplaceScope.of(context).records(RecordKind.investment);
    final pending = items
        .where((r) => r.status == RecordStatus.pending)
        .fold(0, (sum, r) => sum + r.amount);
    return JourneyScaffold(
        title: 'Mes financements',
        subtitle: 'Retrouvez vos intentions et les échanges à venir.',
        root: true,
        tab: 2,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Intentions en attente'),
            const SizedBox(height: 8),
            Text(formatCfa(pending),
                style: const TextStyle(
                    fontSize: 28,
                    color: journeyGreen,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Montant transféré via l’application : 0 FCFA'),
          ]),
          const Divider(),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final status in [
              null,
              RecordStatus.pending,
              RecordStatus.cancelled
            ])
              ChoiceChip(
                  label: Text(status?.label ?? 'Toutes'),
                  selected: _status == status,
                  onSelected: (_) => setState(() => _status = status)),
          ]),
          if (items.isEmpty)
            JourneyEmpty(
                title: 'Aucune intention pour le moment',
                message: 'Consultez les projets pour rencontrer les porteurs.',
                action: JourneyButton(
                    label: 'Voir les projets',
                    onPressed: () async =>
                        openJourney(context, '/investor-projects'))),
          if (items.isNotEmpty &&
              !items.any((r) => _status == null || r.status == _status))
            const JourneyEmpty(
                title: 'Aucune intention dans cette catégorie',
                message:
                    'Vos autres intentions restent disponibles dans Toutes.'),
          ...items.where((r) => _status == null || r.status == _status).map(
              (r) => JourneyCard(
                  padding: EdgeInsets.zero,
                  onTap: () =>
                      openJourney(context, '/record-detail', arguments: r.id),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AspectRatio(
                            aspectRatio: 2.4,
                            child: Image.asset(
                                MarketplaceCatalog.project(r.relatedId).image,
                                fit: BoxFit.cover)),
                        Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.status.label,
                                      style:
                                          const TextStyle(color: journeyMuted)),
                                  const SizedBox(height: 8),
                                  Text(r.title,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 8),
                                  Text(formatCfa(r.amount),
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: journeyGreen)),
                                  Text(
                                      'Intention du ${formatDate(r.createdAt)}'),
                                ])),
                      ]))),
        ]);
  }
}

class InvestorImpactPage extends StatelessWidget {
  const InvestorImpactPage({super.key});
  static const routeName = '/investor-impact';
  @override
  Widget build(BuildContext context) {
    final investments = MarketplaceScope.of(context)
        .records(RecordKind.investment)
        .where((r) => r.status != RecordStatus.cancelled)
        .toList();
    final projects = MarketplaceCatalog.projects
        .where((p) => investments.any((i) => i.relatedId == p.id))
        .toList();
    return JourneyScaffold(title: 'Suivre les impacts', children: [
      const JourneyNotice(
          'Les bénéficiaires et résultats ci-dessous sont des objectifs des projets suivis, pas des impacts réalisés ni attribués à vos intentions.'),
      JourneyCard(
          child: Text(
              '${projects.length} projet(s) suivi(s)\n${projects.fold(0, (sum, p) => sum + p.beneficiaries)} bénéficiaires visés\nAucun rapport de réalisation reçu',
              style: const TextStyle(fontSize: 18, height: 2))),
      if (projects.isEmpty)
        const JourneyEmpty(
            title: 'Aucun projet suivi',
            message: 'Les objectifs des projets soutenus apparaîtront ici.'),
      ...projects.map((p) => ProjectCard(project: p)),
    ]);
  }
}
