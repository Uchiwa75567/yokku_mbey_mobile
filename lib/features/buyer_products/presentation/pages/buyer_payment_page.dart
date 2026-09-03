import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import 'buyer_reservation_confirmation_page.dart';

class BuyerPaymentData {
  const BuyerPaymentData({
    required this.productName,
    required this.quantityKg,
    required this.productAmount,
    required this.amountToPay,
    this.serviceFee = 0,
  });

  final String productName;
  final int quantityKg;
  final int productAmount;
  final int amountToPay;
  final int serviceFee;
}

enum _PaymentMethod { wave, orangeMoney, bankCard }

class BuyerPaymentPage extends StatefulWidget {
  const BuyerPaymentPage({
    this.data = defaultData,
    super.key,
  });

  static const String routeName = '/buyer-payment';
  static const BuyerPaymentData defaultData = BuyerPaymentData(
    productName: 'Tomate fraîche',
    quantityKg: 200,
    productAmount: 80000,
    amountToPay: 80000,
  );

  final BuyerPaymentData data;

  static BuyerPaymentPage fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return BuyerPaymentPage(
      data: arguments is BuyerPaymentData ? arguments : defaultData,
    );
  }

  @override
  State<BuyerPaymentPage> createState() => _BuyerPaymentPageState();
}

class _BuyerPaymentPageState extends State<BuyerPaymentPage> {
  _PaymentMethod _selectedMethod = _PaymentMethod.wave;

  void _pay() {
    Navigator.of(context).pushReplacementNamed(
      BuyerReservationConfirmationPage.routeName,
      arguments: BuyerReservationConfirmationArguments(
        productName: widget.data.productName,
        quantityKg: widget.data.quantityKg,
        amountPaid: widget.data.amountToPay,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 58, 24, 32),
                color: const Color(0xFF087C2E),
                child: Row(
                  children: [
                    IconButton.filled(
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        fixedSize: const Size(48, 48),
                      ),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paiement',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Transaction sécurisée',
                            style: TextStyle(
                              color: Color(0xFFE3F4E8),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(40, 34, 40, 28 + bottomInset),
              sliver: SliverList.list(
                children: [
                  const Text(
                    'Résumé de la commande',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _OrderSummary(data: widget.data),
                  const SizedBox(height: 34),
                  const Text(
                    'Choisir un moyen de paiement',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PaymentMethodCard(
                    selected: _selectedMethod == _PaymentMethod.wave,
                    title: 'Wave',
                    subtitle: 'Paiement mobile',
                    mark: 'W',
                    markColor: const Color(0xFF087C12),
                    onTap: () {
                      setState(() => _selectedMethod = _PaymentMethod.wave);
                    },
                  ),
                  const SizedBox(height: 12),
                  _PaymentMethodCard(
                    selected: _selectedMethod == _PaymentMethod.orangeMoney,
                    title: 'Orange Money',
                    subtitle: 'Paiement mobile',
                    mark: 'O',
                    markColor: const Color(0xFF202A3A),
                    onTap: () {
                      setState(
                        () => _selectedMethod = _PaymentMethod.orangeMoney,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _PaymentMethodCard(
                    selected: _selectedMethod == _PaymentMethod.bankCard,
                    title: 'Carte bancaire',
                    subtitle: 'Visa / Mastercard',
                    icon: Icons.credit_card_rounded,
                    markColor: const Color(0xFF566273),
                    onTap: () {
                      setState(
                        () => _selectedMethod = _PaymentMethod.bankCard,
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                  FilledButton(
                    onPressed: _pay,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(58),
                      backgroundColor: const Color(0xFF076C36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: Text(
                      'Payer ${_formatAmount(widget.data.amountToPay)} FCFA',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Paiement protégé par YOKKU MBEY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF777E8A),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.data});

  final BuyerPaymentData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE8EBEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${data.productName} • ${data.quantityKg} kg',
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _OrderRow(
            label: 'Prix du produit',
            value: '${_formatAmount(data.productAmount)} FCFA',
          ),
          const SizedBox(height: 13),
          _OrderRow(
            label: 'Frais de service',
            value: '${_formatAmount(data.serviceFee)} FCFA',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(height: 1, color: Color(0xFFE8EBEF)),
          ),
          _OrderRow(
            label: 'Total',
            value: '${_formatAmount(data.amountToPay)} FCFA',
            highlighted: true,
          ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: highlighted ? AppColors.ink : const Color(0xFF777E8A),
              fontSize: 15,
              fontWeight: highlighted ? FontWeight.w800 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlighted ? const Color(0xFF087C12) : AppColors.ink,
            fontSize: highlighted ? 18 : 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.markColor,
    required this.onTap,
    this.mark,
    this.icon,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final String? mark;
  final IconData? icon;
  final Color markColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFECFAF2) : AppColors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color:
                  selected ? const Color(0xFF087C2E) : const Color(0xFFE8EBEF),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: const Color(0xFFF7F8FA),
                child: icon != null
                    ? Icon(icon, color: markColor)
                    : Text(
                        mark!,
                        style: TextStyle(
                          color: markColor,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF777E8A),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? const Color(0xFF087C2E) : AppColors.white,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF087C2E)
                        : const Color(0xFFCDD2DA),
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.circle,
                        color: AppColors.white,
                        size: 8,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatAmount(int value) {
  return value.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ' ',
      );
}
