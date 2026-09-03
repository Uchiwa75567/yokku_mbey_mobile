import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'buyer_create_alert_page.dart';

class BuyerAlertDetailPage extends StatelessWidget {
  const BuyerAlertDetailPage({super.key});
  static const routeName = '/buyer-alert-detail';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Détail de l’alerte'),
        backgroundColor: const Color(0xFF087C2E),
        foregroundColor: AppColors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          const Icon(
            Icons.notifications_active_rounded,
            color: Color(0xFF08713B),
            size: 62,
          ),
          const SizedBox(height: 18),
          const Text(
            'Tomate fraîche',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 30),
          const _AlertRow(label: 'Région', value: 'Dakar'),
          const _AlertRow(label: 'Prix maximum', value: '350 FCFA/kg'),
          const _AlertRow(label: 'Quantité minimale', value: '100 kg'),
          const _AlertRow(label: 'Disponibilité', value: 'Maintenant'),
          const _AlertRow(label: 'Fréquence', value: 'Immédiatement'),
          const _AlertRow(label: 'Statut', value: 'Active', green: true),
          const SizedBox(height: 36),
          FilledButton(
            onPressed: () => Navigator.of(context).pushNamed(
              BuyerCreateAlertPage.routeName,
              arguments: const BuyerCreateAlertArguments(
                product: 'Tomate fraîche',
                region: 'Dakar',
                editing: true,
                targetPrice: '350',
                minimumQuantity: '100',
              ),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: const Color(0xFF076735),
            ),
            child: const Text('Modifier l’alerte'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Supprimer cette alerte ?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Annuler'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).pop();
                    },
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Supprimer'),
                  ),
                ],
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer l’alerte'),
          ),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.label,
    required this.value,
    this.green = false,
  });
  final String label;
  final String value;
  final bool green;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(color: Colors.grey)),
            ),
            Text(
              value,
              style: TextStyle(
                color: green ? const Color(0xFF08713B) : AppColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
}
