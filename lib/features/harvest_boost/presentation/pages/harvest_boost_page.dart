import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/farmer_glass_surface.dart';
import '../../../harvest_publication/presentation/pages/harvest_publication_page.dart';
import '../../../home/presentation/widgets/farmer_bottom_navigation.dart';
import '../../../reservations/presentation/pages/reservations_received_page.dart';
import '../../../profile/presentation/pages/farmer_profile_page.dart';

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
  static const double _designWidth = 440;
  static const double _designHeight = 956;
  static const double _bottomNavigationHeight =
      FarmerBottomNavigation.designHeight;

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
            'Paiement de ${_selectedPlan.price} FCFA avec ${_paymentMethodLabel(_paymentMethod!)}',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF18241D),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final scale = (constraints.maxWidth / _designWidth).clamp(0.1, 1.0);
            final scaledWidth = _designWidth * scale;
            final scaledHeight = _designHeight * scale;
            final navHeight = _bottomNavigationHeight * scale;
            final bottomSafeInset = MediaQuery.viewPaddingOf(context).bottom;

            return Center(
              child: SizedBox(
                width: scaledWidth,
                height: constraints.maxHeight,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: navHeight + bottomSafeInset + 18,
                      ),
                      child: SizedBox(
                        width: scaledWidth,
                        height: scaledHeight,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            width: _designWidth,
                            height: _designHeight,
                            child: _HarvestBoostCanvas(
                              harvest: widget.harvest,
                              selectedPlanIndex: _selectedPlanIndex,
                              paymentLabel: _paymentMethod == null
                                  ? 'Wave / Orange Money / Carte'
                                  : _paymentMethodLabel(_paymentMethod!),
                              onPlanSelected: (index) {
                                setState(() => _selectedPlanIndex = index);
                              },
                              onPaymentTap: _selectPaymentMethod,
                              onPay: _startPayment,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: bottomSafeInset,
                      height: navHeight,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        alignment: Alignment.bottomLeft,
                        child: SizedBox(
                          width: _designWidth,
                          height: _bottomNavigationHeight,
                          child: FarmerBottomNavigation(
                            activeTab: FarmerNavigationTab.home,
                            onHome: () => Navigator.of(context).maybePop(),
                            onHarvests: () => Navigator.of(context).maybePop(),
                            onPublishHarvest: () {
                              Navigator.of(context).pushNamed(
                                HarvestPublicationPage.routeName,
                              );
                            },
                            onReservations: () {
                              Navigator.of(context).pushReplacementNamed(
                                ReservationsReceivedPage.routeName,
                              );
                            },
                            onProfile: () {
                              Navigator.of(context).pushNamed(
                                FarmerProfilePage.routeName,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HarvestBoostCanvas extends StatelessWidget {
  const _HarvestBoostCanvas({
    required this.harvest,
    required this.selectedPlanIndex,
    required this.paymentLabel,
    required this.onPlanSelected,
    required this.onPaymentTap,
    required this.onPay,
  });

  final HarvestBoostData harvest;
  final int selectedPlanIndex;
  final String paymentLabel;
  final ValueChanged<int> onPlanSelected;
  final VoidCallback onPaymentTap;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final selectedPlan = _boostPlans[selectedPlanIndex];

    return Stack(
      children: [
        const Positioned.fill(
          child: FarmerGlassBackground(overlayOpacity: 0.46),
        ),
        const Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 166,
          child: FarmerGlassSurface(
            color: Color(0x1AFFFFFF),
            blurSigma: 16,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(26),
            ),
            borderColor: Color(0x33FFFFFF),
            child: SizedBox.expand(),
          ),
        ),
        const Positioned(
          left: 21,
          top: 75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booster l’annonce',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Donner plus de visibilité à votre récolte',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 43,
          right: 47,
          top: 201,
          child: _BoostedHarvestSummary(harvest: harvest),
        ),
        Positioned(
          left: 43,
          right: 47,
          top: 286,
          child: Column(
            children: _boostPlans.indexed.map((entry) {
              final index = entry.$1;
              return Padding(
                padding: EdgeInsets.only(top: index == 0 ? 0 : 17),
                child: _BoostPlanCard(
                  plan: entry.$2,
                  selected: selectedPlanIndex == index,
                  onTap: () => onPlanSelected(index),
                ),
              );
            }).toList(),
          ),
        ),
        Positioned(
          left: 43,
          right: 47,
          top: 542,
          child: _PaymentSelector(
            paymentLabel: paymentLabel,
            onTap: onPaymentTap,
          ),
        ),
        Positioned(
          left: 45,
          right: 45,
          top: 721,
          child: SizedBox(
            height: 56,
            child: FilledButton(
              onPressed: onPay,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF076B2C),
                foregroundColor: AppColors.white,
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: 0.18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              child: Text('Payer ${selectedPlan.price} FCFA'),
            ),
          ),
        ),
      ],
    );
  }
}

class _BoostedHarvestSummary extends StatelessWidget {
  const _BoostedHarvestSummary({required this.harvest});

  final HarvestBoostData harvest;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FAF5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            harvest.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${harvest.quantityLabel} • ${harvest.priceLabel}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF708099),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _BoostPlanCard extends StatelessWidget {
  const _BoostPlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final _BoostPlan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor =
        selected ? const Color(0xFFFF7817) : const Color(0xFF9AA9BD);

    return Material(
      color: selected ? const Color(0xFFFFF6ED) : AppColors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 70,
          padding: const EdgeInsets.fromLTRB(16, 0, 17, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  selected ? const Color(0xFFFF7817) : const Color(0xFFE8EDF3),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.035),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              _PlanRadio(selected: selected, color: accentColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF708099),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${plan.price} FCFA',
                style: const TextStyle(
                  color: Color(0xFFFF7817),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanRadio extends StatelessWidget {
  const _PlanRadio({required this.selected, required this.color});

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: selected ? color : AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: selected ? 2 : 1.5),
      ),
      child: selected
          ? const Center(
              child: SizedBox.square(
                dimension: 7,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _PaymentSelector extends StatelessWidget {
  const _PaymentSelector({
    required this.paymentLabel,
    required this.onTap,
  });

  final String paymentLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F9FB),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 71,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PAIEMENT',
                        style: TextStyle(
                          color: Color(0xFF91A0B5),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        paymentLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF354155),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF91A0B5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
