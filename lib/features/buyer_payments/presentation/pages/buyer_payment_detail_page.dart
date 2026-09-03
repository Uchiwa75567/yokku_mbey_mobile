import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../buyer_support/presentation/pages/buyer_report_problem_page.dart';

enum BuyerPaymentStatus { successful, pending, failed }

class BuyerPaymentRecord {
  const BuyerPaymentRecord({
    required this.reference,
    required this.transactionNumber,
    required this.productName,
    required this.producerName,
    required this.quantityKg,
    required this.amount,
    required this.deposit,
    required this.fees,
    required this.method,
    required this.dateLabel,
    required this.status,
  });

  final String reference;
  final String transactionNumber;
  final String productName;
  final String producerName;
  final int quantityKg;
  final int amount;
  final int deposit;
  final int fees;
  final String method;
  final String dateLabel;
  final BuyerPaymentStatus status;
}

class BuyerPaymentDetailPage extends StatelessWidget {
  const BuyerPaymentDetailPage({super.key, required this.payment});

  static const String routeName = '/buyer-payment-detail';

  final BuyerPaymentRecord payment;

  static Widget fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return BuyerPaymentDetailPage(
      payment: arguments is BuyerPaymentRecord
          ? arguments
          : const BuyerPaymentRecord(
              reference: 'YK-2026-0184',
              transactionNumber: 'WAV-98A72KLM',
              productName: 'Tomate fraîche',
              producerName: 'Ibrahima Ndiaye',
              quantityKg: 200,
              amount: 80000,
              deposit: 0,
              fees: 0,
              method: 'Wave',
              dateLabel: "Aujourd'hui à 10:30",
              status: BuyerPaymentStatus.successful,
            ),
    );
  }

  void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final successful = payment.status == BuyerPaymentStatus.successful;
    final pending = payment.status == BuyerPaymentStatus.pending;
    final statusColor = successful
        ? const Color(0xFF126332)
        : pending
            ? const Color(0xFFF28C00)
            : const Color(0xFFD92D2D);
    final statusLabel = successful
        ? 'Paiement réussi'
        : pending
            ? 'Paiement en attente'
            : 'Paiement échoué';

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
              child: _DetailHeader(reference: payment.reference),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(46, 34, 46, 30 + bottomInset),
              sliver: SliverList.list(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: successful
                          ? const Color(0xFFEDFAF2)
                          : pending
                              ? const Color(0xFFFFF7E9)
                              : const Color(0xFFFFEEEE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          payment.dateLabel.replaceFirst(',', ' à'),
                          style: const TextStyle(
                            color: Color(0xFF697386),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _PaymentRow(label: 'Produit', value: payment.productName),
                  _PaymentRow(
                    label: 'Quantité',
                    value: '${payment.quantityKg} kg',
                  ),
                  _PaymentRow(
                    label: 'Producteur',
                    value: payment.producerName,
                  ),
                  _PaymentRow(
                    label: 'Montant produit',
                    value: '${_formatAmount(payment.amount)} FCFA',
                  ),
                  _PaymentRow(
                    label: 'Acompte',
                    value: '${_formatAmount(payment.deposit)} FCFA',
                  ),
                  _PaymentRow(
                    label: 'Frais',
                    value: '${_formatAmount(payment.fees)} FCFA',
                  ),
                  _PaymentRow(
                    label: 'Total payé',
                    value:
                        '${_formatAmount(payment.amount + payment.fees)} FCFA',
                  ),
                  _PaymentRow(label: 'Moyen', value: payment.method),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFE6EAF0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Numéro de transaction',
                          style: TextStyle(color: Color(0xFF8FA1BA)),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          payment.transactionNumber,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: successful
                        ? () => _message(context, 'Reçu téléchargé')
                        : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(57),
                      backgroundColor: const Color(0xFF076735),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Télécharger le reçu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(
                                text: '${payment.reference} • '
                                    '${payment.transactionNumber}',
                              ),
                            );
                            if (context.mounted) {
                              _message(
                                context,
                                'Référence copiée pour le partage',
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(55),
                            foregroundColor: const Color(0xFF2563EB),
                            side: const BorderSide(color: Color(0xFF2563EB)),
                          ),
                          child: const Text(
                            'Partager',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pushNamed(
                            BuyerReportProblemPage.routeName,
                            arguments: BuyerReportProblemArguments(
                              reference: 'Paiement ${payment.reference}',
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(55),
                            foregroundColor: const Color(0xFFF04444),
                            side: const BorderSide(color: Color(0xFFF04444)),
                          ),
                          child: const Text(
                            'Signaler un problème',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
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

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.reference});

  final String reference;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF087C2E),
      padding: const EdgeInsets.fromLTRB(18, 58, 24, 32),
      child: Row(
        children: [
          IconButton.filled(
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              fixedSize: const Size(48, 48),
              backgroundColor: Colors.white.withValues(alpha: 0.3),
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
                  'Détail du paiement',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Référence $reference',
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
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8FA1BA),
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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
