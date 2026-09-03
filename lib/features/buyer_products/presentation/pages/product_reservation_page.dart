import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import 'buyer_payment_page.dart';

class ProductReservationData {
  const ProductReservationData({
    required this.productName,
    required this.unitPrice,
    required this.quantityLabel,
    required this.recoveryMode,
    this.depositPercentage = 20,
  });

  final String productName;
  final int unitPrice;
  final String quantityLabel;
  final String recoveryMode;
  final int depositPercentage;
}

enum _PaymentOption { full, deposit }

class ProductReservationPage extends StatefulWidget {
  const ProductReservationPage({
    this.data = defaultData,
    super.key,
  });

  static const String routeName = '/product-reservation';
  static const ProductReservationData defaultData = ProductReservationData(
    productName: 'Tomate fraîche',
    unitPrice: 400,
    quantityLabel: '500 kg disponibles • minimum 50 kg',
    recoveryMode: 'Retrait chez le producteur',
  );

  final ProductReservationData data;

  static ProductReservationPage fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return ProductReservationPage(
      data: arguments is ProductReservationData ? arguments : defaultData,
    );
  }

  @override
  State<ProductReservationPage> createState() => _ProductReservationPageState();
}

class _ProductReservationPageState extends State<ProductReservationPage> {
  final TextEditingController _quantityController = TextEditingController(
    text: '200',
  );
  _PaymentOption _paymentOption = _PaymentOption.full;

  int get _quantity => int.tryParse(_quantityController.text.trim()) ?? 0;
  int get _total => _quantity * widget.data.unitPrice;
  int get _amountToPay => _paymentOption == _PaymentOption.full
      ? _total
      : (_total * widget.data.depositPercentage / 100).round();

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Indiquez une quantité valide'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).pushNamed(
      BuyerPaymentPage.routeName,
      arguments: BuyerPaymentData(
        productName: widget.data.productName,
        quantityKg: _quantity,
        productAmount: _total,
        amountToPay: _amountToPay,
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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Réserver le produit',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.data.productName,
                            style: const TextStyle(
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
              padding: EdgeInsets.fromLTRB(42, 32, 42, 30 + bottomInset),
              sliver: SliverList.list(
                children: [
                  _AvailabilityCard(quantityLabel: widget.data.quantityLabel),
                  const SizedBox(height: 28),
                  const _FieldLabel('Quantité souhaitée *'),
                  const SizedBox(height: 9),
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration('200 kg'),
                  ),
                  const SizedBox(height: 24),
                  const _FieldLabel('Montant total'),
                  const SizedBox(height: 9),
                  _AmountBox(value: '${_formatAmount(_total)} FCFA'),
                  const SizedBox(height: 27),
                  const Text(
                    'Option de paiement',
                    style: TextStyle(
                      color: Color(0xFF202A3A),
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _PaymentOptionCard(
                    selected: _paymentOption == _PaymentOption.full,
                    title: 'Payer maintenant',
                    subtitle: 'Transaction sécurisée sur YOKKU',
                    onTap: () {
                      setState(() => _paymentOption = _PaymentOption.full);
                    },
                  ),
                  const SizedBox(height: 12),
                  _PaymentOptionCard(
                    selected: _paymentOption == _PaymentOption.deposit,
                    title: 'Payer un acompte',
                    subtitle: 'Le solde sera payé à la récupération',
                    onTap: () {
                      setState(() => _paymentOption = _PaymentOption.deposit);
                    },
                  ),
                  const SizedBox(height: 25),
                  const _FieldLabel('Mode de récupération'),
                  const SizedBox(height: 9),
                  TextFormField(
                    initialValue: widget.data.recoveryMode,
                    readOnly: true,
                    decoration: _inputDecoration('Mode de récupération'),
                  ),
                  const SizedBox(height: 38),
                  FilledButton(
                    onPressed: _continue,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(58),
                      backgroundColor: const Color(0xFF087C2E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: const Text('Continuer'),
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

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({required this.quantityLabel});

  final String quantityLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 21),
      decoration: BoxDecoration(
        color: const Color(0xFFECFAF2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC8F1D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Produit disponible maintenant',
            style: TextStyle(
              color: Color(0xFF087C3A),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            quantityLabel,
            style: const TextStyle(color: Color(0xFF687284), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _PaymentOptionCard extends StatelessWidget {
  const _PaymentOptionCard({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFECFAF2) : AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  selected ? const Color(0xFF087C3A) : const Color(0xFFE5E8EC),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? const Color(0xFF087C3A) : AppColors.white,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF7C8797),
                    width: selected ? 4 : 1,
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
                        color: Color(0xFF202A3A),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF747E8E),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF202A3A),
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _AmountBox extends StatelessWidget {
  const _AmountBox({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F9),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFFC4CAD3)),
    filled: true,
    fillColor: AppColors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE4E7EB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE4E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF087C3A), width: 1.5),
    ),
  );
}

String _formatAmount(int value) {
  return value.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ' ',
      );
}
