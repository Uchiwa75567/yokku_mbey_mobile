import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class BuyerSavedPaymentMethodsPage extends StatefulWidget {
  const BuyerSavedPaymentMethodsPage({super.key});
  static const routeName = '/buyer-saved-payment-methods';

  @override
  State<BuyerSavedPaymentMethodsPage> createState() =>
      _BuyerSavedPaymentMethodsPageState();
}

class _BuyerSavedPaymentMethodsPageState
    extends State<BuyerSavedPaymentMethodsPage> {
  final List<(IconData, String, String)> _methods = [
    (Icons.phone_android_rounded, 'Wave', '77 ••• •• 00'),
    (Icons.phone_android_rounded, 'Orange Money', '78 ••• •• 00'),
    (Icons.credit_card_rounded, 'Visa', '•••• 4242'),
  ];
  int _defaultIndex = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: const Text('Moyens de paiement'),
          backgroundColor: const Color(0xFF087C2E),
          foregroundColor: Colors.white,
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            FilledButton.icon(
              onPressed: () => setState(
                () => _methods.add(
                  (Icons.credit_card_rounded, 'Nouvelle carte', '•••• 2026'),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Ajouter un moyen de paiement'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: const Color(0xFF076735),
              ),
            ),
            const SizedBox(height: 22),
            ...List.generate(_methods.length, (index) {
              final method = _methods[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: CircleAvatar(child: Icon(method.$1)),
                  title: Text(
                    method.$2,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(method.$3),
                  trailing: IconButton(
                    onPressed: () => setState(() => _defaultIndex = index),
                    icon: Icon(
                      _defaultIndex == index
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: _defaultIndex == index
                          ? const Color(0xFF08713B)
                          : Colors.grey,
                    ),
                  ),
                  onLongPress: () {
                    setState(() {
                      _methods.removeAt(index);
                      _defaultIndex = 0;
                    });
                  },
                ),
              );
            }),
            const SizedBox(height: 12),
            const Text(
              'Appuyez longuement sur un moyen pour le supprimer.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
}
