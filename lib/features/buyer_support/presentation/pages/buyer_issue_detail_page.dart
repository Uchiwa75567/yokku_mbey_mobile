import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class BuyerIssueDetailArguments {
  const BuyerIssueDetailArguments({
    this.reference = 'SIG-2026-0042',
    this.orderReference = 'YK-2026-0184',
  });
  final String reference;
  final String orderReference;
}

class BuyerIssueDetailPage extends StatelessWidget {
  const BuyerIssueDetailPage({super.key, required this.arguments});
  static const routeName = '/buyer-issue-detail';
  final BuyerIssueDetailArguments arguments;

  static Widget fromRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    return BuyerIssueDetailPage(
      arguments: args is BuyerIssueDetailArguments
          ? args
          : const BuyerIssueDetailArguments(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Suivi du signalement'),
        backgroundColor: const Color(0xFF087C2E),
        foregroundColor: AppColors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5E9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'En cours d’examen',
                  style: TextStyle(
                    color: Color(0xFFF28C00),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text('Réponse estimée sous 24 heures'),
              ],
            ),
          ),
          const SizedBox(height: 26),
          _IssueRow(label: 'Signalement', value: arguments.reference),
          _IssueRow(label: 'Commande', value: arguments.orderReference),
          const _IssueRow(label: 'Motif', value: 'Produit non conforme'),
          const _IssueRow(label: 'Créé le', value: 'Aujourd’hui, 10:45'),
          const SizedBox(height: 30),
          const Text(
            'Progression',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          const _IssueStep(
            title: 'Signalement envoyé',
            subtitle: 'Votre dossier a bien été enregistré',
            done: true,
          ),
          const _IssueStep(
            title: 'Analyse par YOKKU',
            subtitle: 'Notre équipe vérifie les éléments transmis',
            done: true,
          ),
          const _IssueStep(
            title: 'Réponse et résolution',
            subtitle: 'En attente',
            done: false,
          ),
          const SizedBox(height: 30),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              foregroundColor: const Color(0xFF076735),
            ),
            child: const Text('Retour à mes achats'),
          ),
        ],
      ),
    );
  }
}

class _IssueRow extends StatelessWidget {
  const _IssueRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
                child: Text(label, style: const TextStyle(color: Colors.grey))),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      );
}

class _IssueStep extends StatelessWidget {
  const _IssueStep({
    required this.title,
    required this.subtitle,
    required this.done,
  });
  final String title;
  final String subtitle;
  final bool done;
  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: done ? const Color(0xFF08713B) : Colors.white,
          child: Icon(
            done ? Icons.check_rounded : Icons.schedule_rounded,
            color: done ? Colors.white : Colors.grey,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
      );
}
