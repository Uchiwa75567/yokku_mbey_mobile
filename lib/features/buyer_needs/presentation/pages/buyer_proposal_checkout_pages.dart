import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'buyer_proposal_detail_page.dart';

class BuyerProposalAcceptedPage extends StatelessWidget {
  const BuyerProposalAcceptedPage({super.key, required this.proposal});
  static const routeName = '/buyer-proposal-accepted';
  final BuyerProposalData proposal;

  static Widget fromRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    return BuyerProposalAcceptedPage(
      proposal: args is BuyerProposalData ? args : _defaultProposal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final deposit = proposal.quantityKg *
        proposal.unitPrice *
        proposal.depositPercentage ~/
        100;
    return _SuccessScaffold(
      icon: Icons.handshake_outlined,
      title: 'Offre acceptée avec succès',
      message:
          'L’offre de ${proposal.producerName} a été retenue. Payez l’acompte pour confirmer.',
      details: [
        'Répondu',
        '${proposal.quantityKg} kg de ${proposal.productName}',
        '${proposal.unitPrice} FCFA/kg',
        'Acompte : ${_amount(deposit)} FCFA',
      ],
      primaryLabel: 'Payer l’acompte',
      onPrimary: () => Navigator.of(context).pushReplacementNamed(
        BuyerProposalPaymentPage.routeName,
        arguments: proposal,
      ),
    );
  }
}

class BuyerProposalPaymentPage extends StatefulWidget {
  const BuyerProposalPaymentPage({super.key, required this.proposal});
  static const routeName = '/buyer-proposal-payment';
  final BuyerProposalData proposal;

  static Widget fromRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    return BuyerProposalPaymentPage(
      proposal: args is BuyerProposalData ? args : _defaultProposal,
    );
  }

  @override
  State<BuyerProposalPaymentPage> createState() =>
      _BuyerProposalPaymentPageState();
}

class _BuyerProposalPaymentPageState extends State<BuyerProposalPaymentPage> {
  String _method = 'Wave';

  @override
  Widget build(BuildContext context) {
    final total = widget.proposal.quantityKg * widget.proposal.unitPrice;
    final deposit = total * widget.proposal.depositPercentage ~/ 100;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Paiement de la proposition'),
        backgroundColor: const Color(0xFF087C2E),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          Text(
            widget.proposal.productName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 22),
          _CheckoutRow(label: 'Montant total', value: '${_amount(total)} FCFA'),
          _CheckoutRow(
            label: 'Acompte (${widget.proposal.depositPercentage} %)',
            value: '${_amount(deposit)} FCFA',
          ),
          const SizedBox(height: 28),
          const Text(
            'Moyen de paiement',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          for (final method in ['Wave', 'Orange Money', 'Carte bancaire'])
            ListTile(
              onTap: () => setState(() => _method = method),
              leading: Icon(
                _method == method
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color:
                    _method == method ? const Color(0xFF08713B) : Colors.grey,
              ),
              title: Text(method),
            ),
          const SizedBox(height: 36),
          FilledButton(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => _SuccessScaffold(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Paiement confirmé',
                  message:
                      'Votre acompte a été payé avec $_method. La réservation est confirmée.',
                  details: const ['Référence YK-2026-0185'],
                  primaryLabel: 'Terminer',
                  onPrimary: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                ),
              ),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(58),
              backgroundColor: const Color(0xFF076735),
            ),
            child: Text('Payer ${_amount(deposit)} FCFA'),
          ),
        ],
      ),
    );
  }
}

class _SuccessScaffold extends StatelessWidget {
  const _SuccessScaffold({
    required this.icon,
    required this.title,
    required this.message,
    required this.details,
    required this.primaryLabel,
    required this.onPrimary,
  });
  final IconData icon;
  final String title;
  final String message;
  final List<String> details;
  final String primaryLabel;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: const Color(0xFF08713B),
                  child: Icon(icon, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 28),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 28),
                ...details.map(
                  (detail) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      detail,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 42),
                FilledButton(
                  onPressed: onPrimary,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: const Color(0xFF076735),
                  ),
                  child: Text(primaryLabel),
                ),
              ],
            ),
          ),
        ),
      );
}

class _CheckoutRow extends StatelessWidget {
  const _CheckoutRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      );
}

const _defaultProposal = BuyerProposalData(
  producerName: 'Ibrahima Ndiaye',
  rating: 4.8,
  sales: 23,
  productName: 'Tomate fraîche',
  quantityKg: 1000,
  unitPrice: 425,
  availability: '15 au 20 juillet',
  location: 'Kaolack',
  recoveryMode: 'Retrait producteur',
  depositPercentage: 20,
  avatarColor: Color(0xFF087C2E),
  avatarBackground: Color(0xFFEDFCF3),
);

String _amount(int value) => value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ' ',
    );
