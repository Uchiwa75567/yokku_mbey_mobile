import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import 'buyer_proposal_detail_page.dart';

enum _ProposalSort { all, cheapest, bestRated }

class BuyerProposalsArguments {
  const BuyerProposalsArguments({
    required this.productName,
    required this.quantity,
  });

  final String productName;
  final String quantity;
}

class BuyerProposalsPage extends StatefulWidget {
  const BuyerProposalsPage({super.key, required this.arguments});

  static const String routeName = '/buyer-proposals';

  final BuyerProposalsArguments arguments;

  static Widget fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return BuyerProposalsPage(
      arguments: arguments is BuyerProposalsArguments
          ? arguments
          : const BuyerProposalsArguments(
              productName: 'Tomate fraîche',
              quantity: '1 000 kg',
            ),
    );
  }

  @override
  State<BuyerProposalsPage> createState() => _BuyerProposalsPageState();
}

class _BuyerProposalsPageState extends State<BuyerProposalsPage> {
  _ProposalSort _sort = _ProposalSort.all;

  List<BuyerProposalData> get _proposals {
    final proposals = List<BuyerProposalData>.of(_initialProposals);
    return switch (_sort) {
      _ProposalSort.all => proposals,
      _ProposalSort.cheapest => proposals
        ..sort((a, b) => a.unitPrice.compareTo(b.unitPrice)),
      _ProposalSort.bestRated => proposals
        ..sort((a, b) => b.rating.compareTo(a.rating)),
    };
  }

  void _openOffer(BuyerProposalData proposal) {
    Navigator.of(context).pushNamed(
      BuyerProposalDetailPage.routeName,
      arguments: proposal,
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
              child: _ProposalsHeader(arguments: widget.arguments),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _ProposalFiltersDelegate(
                selected: _sort,
                onChanged: (value) => setState(() => _sort = value),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(38, 20, 38, 28 + bottomInset),
              sliver: SliverList.separated(
                itemCount: _proposals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final proposal = _proposals[index];
                  return _ProposalCard(
                    proposal: proposal,
                    onOpen: () => _openOffer(proposal),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProposalsHeader extends StatelessWidget {
  const _ProposalsHeader({required this.arguments});

  final BuyerProposalsArguments arguments;

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
                  'Propositions reçues',
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
                  '${arguments.productName} • ${arguments.quantity}',
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

class _ProposalFiltersDelegate extends SliverPersistentHeaderDelegate {
  const _ProposalFiltersDelegate({
    required this.selected,
    required this.onChanged,
  });

  final _ProposalSort selected;
  final ValueChanged<_ProposalSort> onChanged;

  @override
  double get minExtent => 73;

  @override
  double get maxExtent => 73;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
        child: Row(
          children: [
            _FilterButton(
              label: 'Toutes',
              selected: selected == _ProposalSort.all,
              onTap: () => onChanged(_ProposalSort.all),
            ),
            const SizedBox(width: 12),
            _FilterButton(
              label: 'Moins chères',
              selected: selected == _ProposalSort.cheapest,
              onTap: () => onChanged(_ProposalSort.cheapest),
            ),
            const SizedBox(width: 12),
            _FilterButton(
              label: 'Mieux notées',
              selected: selected == _ProposalSort.bestRated,
              onTap: () => onChanged(_ProposalSort.bestRated),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_ProposalFiltersDelegate oldDelegate) {
    return oldDelegate.selected != selected;
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 43,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            backgroundColor:
                selected ? const Color(0xFFF0F8F4) : AppColors.white,
            foregroundColor:
                selected ? const Color(0xFF06723B) : const Color(0xFF697386),
            side: BorderSide(
              color:
                  selected ? const Color(0xFF06723B) : const Color(0xFFE6E9EE),
              width: selected ? 2 : 1,
            ),
            shape: const StadiumBorder(),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  const _ProposalCard({required this.proposal, required this.onOpen});

  final BuyerProposalData proposal;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: proposal.avatarBackground,
                child: Icon(
                  Icons.person_rounded,
                  color: proposal.avatarColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proposal.producerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${proposal.ratingLabel} ★  •  Vérifié',
                      style: const TextStyle(
                        color: Color(0xFF087C2E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Text(
            '${proposal.quantityKg} kg • ${proposal.unitPrice} FCFA/kg',
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'Disponible : ${proposal.availability}',
            style: const TextStyle(color: Color(0xFF697386)),
          ),
          const SizedBox(height: 3),
          Text(
            proposal.depositPercentage == 0
                ? 'Sans acompte'
                : 'Acompte ${proposal.depositPercentage} %',
            style: const TextStyle(color: Color(0xFF697386)),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: onOpen,
              style: FilledButton.styleFrom(
                minimumSize: const Size(117, 42),
                backgroundColor: const Color(0xFF08752E),
                shape: const StadiumBorder(),
              ),
              child: const Text(
                "Voir l'offre",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _initialProposals = [
  BuyerProposalData(
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
  BuyerProposalData(
    producerName: 'Moussa Fall',
    rating: 4.6,
    sales: 18,
    productName: 'Tomate fraîche',
    quantityKg: 900,
    unitPrice: 410,
    availability: '18 au 25 juillet',
    location: 'Thiès',
    recoveryMode: 'Livraison',
    depositPercentage: 0,
    avatarColor: Color(0xFF3478F6),
    avatarBackground: Color(0xFFEDF5FF),
  ),
  BuyerProposalData(
    producerName: 'Aminata Ba',
    rating: 4.9,
    sales: 31,
    productName: 'Tomate fraîche',
    quantityKg: 1000,
    unitPrice: 440,
    availability: '12 au 16 juillet',
    location: 'Dakar',
    recoveryMode: 'Retrait producteur',
    depositPercentage: 10,
    avatarColor: Color(0xFFFF6A00),
    avatarBackground: Color(0xFFFFF4E8),
  ),
];
