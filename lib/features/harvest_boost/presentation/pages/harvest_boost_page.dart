import '../../../../core/widgets/journey_scaffold.dart';
import 'package:flutter/material.dart';

class HarvestBoostData {
  const HarvestBoostData({
    required this.name,
    required this.quantityLabel,
    required this.priceLabel,
  });

  final String name;
  final String quantityLabel;
  final String priceLabel;
}

enum _PaymentMethod { wave, orangeMoney, card }

class HarvestBoostPage extends StatefulWidget {
  const HarvestBoostPage({
    super.key,
    required this.harvest,
  });

  static const String routeName = '/harvest-boost';

  static const HarvestBoostData defaultHarvest = HarvestBoostData(
    name: 'Tomate fraîche',
    quantityLabel: '500 kg',
    priceLabel: '400 FCFA/kg',
  );

  final HarvestBoostData harvest;

  static Widget fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return HarvestBoostPage(
      harvest: arguments is HarvestBoostData ? arguments : defaultHarvest,
    );
  }

  @override
  State<HarvestBoostPage> createState() => _HarvestBoostPageState();
}

class _HarvestBoostPageState extends State<HarvestBoostPage> {
  int _selectedPlanIndex = 1;
  _PaymentMethod? _paymentMethod;

  _BoostPlan get _selectedPlan => _boostPlans[_selectedPlanIndex];

  Future<void> _selectPaymentMethod() async {
    final selectedMethod = await showModalBottomSheet<_PaymentMethod>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PaymentMethodTile(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Wave',
                onTap: () => Navigator.of(context).pop(_PaymentMethod.wave),
              ),
              _PaymentMethodTile(
                icon: Icons.phone_android_outlined,
                label: 'Orange Money',
                onTap: () =>
                    Navigator.of(context).pop(_PaymentMethod.orangeMoney),
              ),
              _PaymentMethodTile(
                icon: Icons.credit_card_outlined,
                label: 'Carte bancaire',
                onTap: () => Navigator.of(context).pop(_PaymentMethod.card),
              ),
            ],
          ),
        );
      },
    );

    if (selectedMethod != null && mounted) {
      setState(() => _paymentMethod = selectedMethod);
    }
  }

  void _startPayment() {
    if (_paymentMethod == null) {
      _selectPaymentMethod();
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Aperçu : ${_selectedPlan.price} FCFA via ${_paymentMethodLabel(_paymentMethod!)}. Aucun paiement effectué.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) => JourneyScaffold(
          title: 'Booster ma récolte',
          subtitle: widget.harvest.name,
          children: [
            const JourneyHeading('Choisir une durée'),
            for (final entry in _boostPlans.indexed)
              JourneyCard(
                  onTap: () => setState(() => _selectedPlanIndex = entry.$1),
                  child: Row(children: [
                    Icon(
                        _selectedPlanIndex == entry.$1
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: journeyGreen),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(entry.$2.title,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(entry.$2.description,
                              style: const TextStyle(color: journeyMuted)),
                          const SizedBox(height: 8),
                          Text('${entry.$2.price} FCFA',
                              style: const TextStyle(
                                  color: journeyGreen,
                                  fontWeight: FontWeight.w700)),
                        ])),
                  ])),
            const Divider(),
            ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: const Text('Moyen de paiement'),
                subtitle: Text(_paymentMethod == null
                    ? 'Wave / Orange Money / Carte'
                    : _paymentMethodLabel(_paymentMethod!)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectPaymentMethod),
            const JourneyNotice(
                'La mise en avant et les paiements ne sont pas connectés. Aucun montant ne sera débité.'),
            JourneyButton(
                label: 'Continuer',
                icon: Icons.arrow_forward,
                onPressed: () async => _startPayment()),
          ]);
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF087C3A)),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _BoostPlan {
  const _BoostPlan({
    required this.title,
    required this.description,
    required this.price,
  });

  final String title;
  final String description;
  final int price;
}

const List<_BoostPlan> _boostPlans = [
  _BoostPlan(
    title: 'Boost 24 h',
    description: 'Mise en avant pendant une journée',
    price: 500,
  ),
  _BoostPlan(
    title: 'Boost 3 jours',
    description: 'Recommandé pour vendre rapidement',
    price: 1000,
  ),
  _BoostPlan(
    title: 'Boost 7 jours',
    description: 'Visibilité maximale sur une semaine',
    price: 2000,
  ),
];

String _paymentMethodLabel(_PaymentMethod method) {
  return switch (method) {
    _PaymentMethod.wave => 'Wave',
    _PaymentMethod.orangeMoney => 'Orange Money',
    _PaymentMethod.card => 'Carte bancaire',
  };
}
