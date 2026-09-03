import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import 'buyer_proposal_checkout_pages.dart';

class BuyerProposalData {
  const BuyerProposalData({
    required this.producerName,
    required this.rating,
    required this.sales,
    required this.productName,
    required this.quantityKg,
    required this.unitPrice,
    required this.availability,
    required this.location,
    required this.recoveryMode,
    required this.depositPercentage,
    required this.avatarColor,
    required this.avatarBackground,
  });

  final String producerName;
  final double rating;
  final int sales;
  final String productName;
  final int quantityKg;
  final int unitPrice;
  final String availability;
  final String location;
  final String recoveryMode;
  final int depositPercentage;
  final Color avatarColor;
  final Color avatarBackground;

  String get ratingLabel => rating.toStringAsFixed(1).replaceAll('.', ',');
}

class BuyerProposalDetailPage extends StatefulWidget {
  const BuyerProposalDetailPage({super.key, required this.proposal});

  static const String routeName = '/buyer-proposal-detail';

  final BuyerProposalData proposal;

  static Widget fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return BuyerProposalDetailPage(
      proposal: arguments is BuyerProposalData
          ? arguments
          : const BuyerProposalData(
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
            ),
    );
  }

  @override
  State<BuyerProposalDetailPage> createState() =>
      _BuyerProposalDetailPageState();
}

class _BuyerProposalDetailPageState extends State<BuyerProposalDetailPage> {
  bool _responded = false;

  Future<void> _respond(bool accepted) async {
    final action = accepted ? 'accepter' : 'refuser';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${accepted ? 'Accepter' : 'Refuser'} cette offre ?'),
        content: Text(
          'Voulez-vous vraiment $action la proposition de '
          '${widget.proposal.producerName} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Retour'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor:
                  accepted ? const Color(0xFF08752E) : const Color(0xFFF04444),
            ),
            child: Text(accepted ? "Accepter l'offre" : 'Refuser'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      if (accepted) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => BuyerProposalAcceptedPage(
              proposal: widget.proposal,
            ),
          ),
        );
        return;
      }
      setState(() => _responded = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offre refusée')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final proposal = widget.proposal;
    final total = proposal.quantityKg * proposal.unitPrice;
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
            const SliverToBoxAdapter(child: _OfferHeader()),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(32, 20, 32, 30 + bottomInset),
              sliver: SliverList.list(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FAF5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 27,
                          backgroundColor: AppColors.white,
                          child: Icon(
                            Icons.person_rounded,
                            color: proposal.avatarColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                proposal.producerName,
                                style: const TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                'Producteur vérifié • ${proposal.ratingLabel}  '
                                '• ${proposal.sales} ventes',
                                style: const TextStyle(
                                  color: Color(0xFF087C2E),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _OfferRow(label: 'Produit', value: proposal.productName),
                  _OfferRow(
                    label: 'Quantité proposée',
                    value: '${proposal.quantityKg} kg',
                  ),
                  _OfferRow(
                    label: 'Prix unitaire',
                    value: '${proposal.unitPrice} FCFA/kg',
                  ),
                  _OfferRow(
                    label: 'Montant total',
                    value: '${_formatAmount(total)} FCFA',
                  ),
                  _OfferRow(
                    label: 'Disponibilité',
                    value: proposal.availability,
                  ),
                  _OfferRow(label: 'Localisation', value: proposal.location),
                  _OfferRow(
                    label: 'Récupération',
                    value: proposal.recoveryMode,
                  ),
                  _OfferRow(
                    label: 'Acompte',
                    value: '${proposal.depositPercentage} %',
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Message du producteur',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Produit disponible selon la période indiquée. '
                    'Quantité complète garantie.',
                    style: TextStyle(
                      color: Color(0xFF697386),
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 34),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _responded ? null : () => _respond(false),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                            foregroundColor: const Color(0xFFF04444),
                            side: const BorderSide(color: Color(0xFFF04444)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: const Text(
                            'Refuser',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _responded ? null : () => _respond(true),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                            backgroundColor: const Color(0xFF08752E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: Text(
                            _responded ? 'Répondu' : "Accepter l'offre",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
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

class _OfferHeader extends StatelessWidget {
  const _OfferHeader();

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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Détail de la proposition',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Offre valable 48 heures',
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
    );
  }
}

class _OfferRow extends StatelessWidget {
  const _OfferRow({required this.label, required this.value});

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
                color: Color(0xFF697386),
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
