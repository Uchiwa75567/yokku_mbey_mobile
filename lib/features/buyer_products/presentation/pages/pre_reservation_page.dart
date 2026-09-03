import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import 'buyer_payment_page.dart';

class PreReservationData {
  const PreReservationData({
    required this.productName,
    required this.unitPrice,
    required this.availabilityLabel,
    required this.depositPercentage,
    required this.recoveryMode,
  });

  final String productName;
  final int unitPrice;
  final String availabilityLabel;
  final int depositPercentage;
  final String recoveryMode;
}

class PreReservationPage extends StatefulWidget {
  const PreReservationPage({
    this.data = defaultData,
    super.key,
  });

  static const String routeName = '/pre-reservation';
  static const PreReservationData defaultData = PreReservationData(
    productName: 'Pomme de terre',
    unitPrice: 500,
    availabilityLabel: 'Disponible entre le 15 et le 25 juillet',
    depositPercentage: 20,
    recoveryMode: 'Retrait chez le producteur',
  );

  final PreReservationData data;

  static PreReservationPage fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return PreReservationPage(
      data: arguments is PreReservationData ? arguments : defaultData,
    );
  }

  @override
  State<PreReservationPage> createState() => _PreReservationPageState();
}

class _PreReservationPageState extends State<PreReservationPage> {
  final TextEditingController _quantityController = TextEditingController(
    text: '200',
  );
  final TextEditingController _messageController = TextEditingController();

  int get _quantity => int.tryParse(_quantityController.text.trim()) ?? 0;
  int get _estimatedPrice => _quantity * widget.data.unitPrice;
  int get _deposit =>
      (_estimatedPrice * widget.data.depositPercentage / 100).round();

  @override
  void dispose() {
    _quantityController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _continueToPayment() {
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
        productAmount: _estimatedPrice,
        amountToPay: _deposit,
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pré-réserver',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Récoltes disponibles prochainement',
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
              padding: EdgeInsets.fromLTRB(30, 26, 30, 30 + bottomInset),
              sliver: SliverList.list(
                children: [
                  _UpcomingProductCard(data: widget.data),
                  const SizedBox(height: 28),
                  const _FieldLabel('Quantité souhaitée *'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration('Ex. 200 kg'),
                  ),
                  const SizedBox(height: 22),
                  const _FieldLabel('Prix estimé'),
                  const SizedBox(height: 8),
                  _AmountBox(
                    value: '${_formatAmount(_estimatedPrice)} FCFA',
                  ),
                  const SizedBox(height: 22),
                  const _FieldLabel('Acompte à payer'),
                  const SizedBox(height: 8),
                  _AmountBox(
                    value: '${_formatAmount(_deposit)} FCFA',
                    highlighted: true,
                  ),
                  const SizedBox(height: 22),
                  const _FieldLabel('Mode de récupération'),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: widget.data.recoveryMode,
                    readOnly: true,
                    decoration: _inputDecoration('Mode de récupération'),
                  ),
                  const SizedBox(height: 22),
                  const _FieldLabel('Message au producteur'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageController,
                    minLines: 4,
                    maxLines: 5,
                    decoration: _inputDecoration('Précisez votre besoin...'),
                  ),
                  const SizedBox(height: 34),
                  FilledButton(
                    onPressed: _continueToPayment,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(58),
                      backgroundColor: const Color(0xFF0A6533),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: const Text('Continuer vers le paiement'),
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

class _UpcomingProductCard extends StatelessWidget {
  const _UpcomingProductCard({required this.data});

  final PreReservationData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFFF6A00)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.productName,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data.availabilityLabel,
            style: const TextStyle(color: Color(0xFF687284), fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            'Acompte demandé : ${data.depositPercentage} %',
            style: const TextStyle(
              color: Color(0xFFFF6A00),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
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
  const _AmountBox({required this.value, this.highlighted = false});

  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFECFAF2) : const Color(0xFFF7F8F9),
        borderRadius: BorderRadius.circular(9),
        border: highlighted ? Border.all(color: const Color(0xFFC7F0D6)) : null,
      ),
      child: Text(
        value,
        style: TextStyle(
          color: highlighted ? const Color(0xFF11663E) : AppColors.ink,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF7B8494)),
    filled: true,
    fillColor: AppColors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: Color(0xFFE0E4E9)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: Color(0xFFE0E4E9)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
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
