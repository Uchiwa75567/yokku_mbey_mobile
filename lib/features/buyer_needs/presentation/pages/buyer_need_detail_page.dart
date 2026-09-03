import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import 'buyer_proposals_page.dart';
import 'publish_buyer_need_page.dart';

class BuyerNeedDetailArguments {
  const BuyerNeedDetailArguments({
    required this.productName,
    required this.quantity,
    required this.region,
    required this.proposals,
  });

  final String productName;
  final String quantity;
  final String region;
  final int proposals;
}

class BuyerNeedDetailPage extends StatefulWidget {
  const BuyerNeedDetailPage({super.key, required this.arguments});

  static const String routeName = '/buyer-need-detail';

  final BuyerNeedDetailArguments arguments;

  static Widget fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return BuyerNeedDetailPage(
      arguments: arguments is BuyerNeedDetailArguments
          ? arguments
          : const BuyerNeedDetailArguments(
              productName: 'Tomate fraîche',
              quantity: '1 000 kg',
              region: 'Dakar ou Thiès',
              proposals: 4,
            ),
    );
  }

  @override
  State<BuyerNeedDetailPage> createState() => _BuyerNeedDetailPageState();
}

class _BuyerNeedDetailPageState extends State<BuyerNeedDetailPage> {
  bool _cancelled = false;

  void _showProposals() {
    Navigator.of(context).pushNamed(
      BuyerProposalsPage.routeName,
      arguments: BuyerProposalsArguments(
        productName: widget.arguments.productName,
        quantity: widget.arguments.quantity,
      ),
    );
  }

  Future<void> _cancelNeed() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la demande ?'),
        content: const Text(
          'Les producteurs ne pourront plus envoyer de propositions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Conserver'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Annuler la demande'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _cancelled = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final arguments = widget.arguments;

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
              child: _DetailHeader(cancelled: _cancelled),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(32, 20, 32, 30 + bottomInset),
              sliver: SliverList.list(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FAF5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          arguments.productName,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          '${arguments.proposals} propositions reçues',
                          style: const TextStyle(
                            color: Color(0xFF138442),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _DetailRow(label: 'Quantité', value: arguments.quantity),
                  _DetailRow(
                    label: 'Région souhaitée',
                    value: arguments.region,
                  ),
                  const _DetailRow(
                    label: 'Budget maximum',
                    value: '450 FCFA/kg',
                  ),
                  const _DetailRow(
                    label: 'Date souhaitée',
                    value: '20 juillet 2026',
                  ),
                  const _DetailRow(
                    label: 'Date de publication',
                    value: '18 juin 2026',
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Recherche de tomates fraîches et mûres pour '
                    'approvisionner plusieurs points de vente.',
                    style: TextStyle(
                      color: Color(0xFF697386),
                      fontSize: 16,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _StatusRow(
                          label: 'Statut',
                          value: _cancelled ? 'Annulée' : 'Active',
                          color:
                              _cancelled ? Colors.red : const Color(0xFF138442),
                        ),
                        const SizedBox(height: 10),
                        _StatusRow(
                          label: 'Expiration',
                          value: _cancelled ? '—' : 'Dans 3 jours',
                          color: _cancelled
                              ? const Color(0xFF697386)
                              : const Color(0xFFFF7A00),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _cancelled
                              ? null
                              : () => Navigator.of(context).pushNamed(
                                    PublishBuyerNeedPage.routeName,
                                    arguments: PublishBuyerNeedArguments(
                                      editing: true,
                                      product: arguments.productName,
                                      quantity: arguments.quantity
                                          .replaceAll(RegExp(r'[^0-9]'), ''),
                                      region: arguments.region,
                                      budget: '450',
                                      date: '20/07/2026',
                                      details:
                                          'Tomates mûres et disponibles en gros.',
                                    ),
                                  ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(61),
                            foregroundColor: const Color(0xFF2463EB),
                            side: const BorderSide(color: Color(0xFF2463EB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: const Text(
                            'Modifier',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _cancelled ? null : _showProposals,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(61),
                            backgroundColor: const Color(0xFF076735),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: const Text(
                            'Voir les\npropositions',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  TextButton(
                    onPressed: _cancelled ? null : _cancelNeed,
                    child: Text(
                      _cancelled ? 'Demande annulée' : 'Annuler la demande',
                      style: const TextStyle(
                        color: Color(0xFFF04444),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
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

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.cancelled});

  final bool cancelled;

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
                  'Détail de la demande',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cancelled ? 'Demande annulée' : 'Demande active',
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

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
                fontSize: 16,
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
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Color(0xFFA0A8B6))),
        ),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
