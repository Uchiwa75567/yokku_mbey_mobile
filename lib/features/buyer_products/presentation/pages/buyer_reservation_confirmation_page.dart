import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../buyer_purchases/presentation/pages/buyer_order_tracking_page.dart';

class BuyerReservationConfirmationArguments {
  const BuyerReservationConfirmationArguments({
    required this.productName,
    required this.quantityKg,
    required this.amountPaid,
    this.reference = 'YK-2026-0184',
  });

  final String productName;
  final int quantityKg;
  final int amountPaid;
  final String reference;
}

class BuyerReservationConfirmationPage extends StatelessWidget {
  const BuyerReservationConfirmationPage({
    super.key,
    required this.arguments,
  });

  static const String routeName = '/buyer-reservation-confirmation';

  final BuyerReservationConfirmationArguments arguments;

  static Widget fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return BuyerReservationConfirmationPage(
      arguments: arguments is BuyerReservationConfirmationArguments
          ? arguments
          : const BuyerReservationConfirmationArguments(
              productName: 'Tomate fraîche',
              quantityKg: 200,
              amountPaid: 80000,
            ),
    );
  }

  void _viewReservation(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(
      BuyerOrderTrackingPage.routeName,
      arguments: BuyerOrderTrackingArguments(
        productName: arguments.productName,
        quantityKg: arguments.quantityKg,
        amount: arguments.amountPaid,
        orderNumber: arguments.reference,
        completedSteps: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(22, 42, 22, 28 + bottomInset),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.sizeOf(context).height -
                    MediaQuery.paddingOf(context).vertical -
                    70,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 34, 24, 30),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: const BoxDecoration(
                        color: Color(0xFF07920D),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.white,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Réservation confirmée !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 13),
                    const Text(
                      'Votre paiement a été enregistré avec succès.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF526071),
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 34),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCFDFD),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFDCE2E8)),
                      ),
                      child: Column(
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: arguments.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                TextSpan(
                                  text: ' • ${arguments.quantityKg} kg',
                                ),
                              ],
                            ),
                            style: const TextStyle(
                              color: Color(0xFF101828),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _SummaryRow(
                            label: 'Montant payé',
                            value:
                                '${_formatAmount(arguments.amountPaid)} FCFA',
                          ),
                          const SizedBox(height: 13),
                          const _SummaryRow(
                            label: 'Statut',
                            value: 'En attente du producteur',
                            valueColor: Color(0xFFFF6B0B),
                          ),
                          const SizedBox(height: 13),
                          _SummaryRow(
                            label: 'Référence',
                            value: arguments.reference,
                            bold: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 38),
                    const Text(
                      "Vous serez notifié dès qu'il confirmera.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF526071),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 54),
                    FilledButton(
                      onPressed: () => _viewReservation(context),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(58),
                        backgroundColor: const Color(0xFF087A0B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Voir ma réservation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context)
                          .popUntil((route) => route.isFirst),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        foregroundColor: AppColors.ink,
                        side: const BorderSide(color: Color(0xFF087A0B)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Retour à l'accueil",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor = AppColors.ink,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF344054),
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor,
              fontSize: 15,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

String _formatAmount(int value) {
  return value.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ' ',
      );
}
