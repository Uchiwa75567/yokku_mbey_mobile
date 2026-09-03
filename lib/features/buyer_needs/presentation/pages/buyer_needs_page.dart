import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../buyer_purchases/presentation/pages/buyer_purchases_page.dart';
import '../../../home/presentation/widgets/buyer_bottom_navigation.dart';
import '../../../buyer_profile/presentation/pages/buyer_profile_page.dart';
import 'buyer_need_detail_page.dart';
import 'publish_buyer_need_page.dart';

enum _NeedStatus { active, waiting }

class BuyerNeedsPage extends StatelessWidget {
  const BuyerNeedsPage({super.key});

  static const String routeName = '/buyer-needs';

  void _openNewNeed(BuildContext context) {
    Navigator.of(context).pushNamed(PublishBuyerNeedPage.routeName);
  }

  void _showNeed(BuildContext context, _BuyerNeed need) {
    Navigator.of(context).pushNamed(
      BuyerNeedDetailPage.routeName,
      arguments: BuyerNeedDetailArguments(
        productName: need.name,
        quantity: need.quantity,
        region: need.location,
        proposals: need.proposals,
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
            const SliverToBoxAdapter(child: _NeedsHeader()),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(34, 26, 34, 118 + bottomInset),
              sliver: SliverList.list(
                children: [
                  FilledButton.icon(
                    onPressed: () => _openNewNeed(context),
                    icon: const Icon(Icons.add_rounded, size: 25),
                    label: const Text(
                      'Nouvelle demande',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(61),
                      backgroundColor: const Color(0xFF07572F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withValues(alpha: 0.15),
                    ),
                  ),
                  const SizedBox(height: 24),
                  for (var index = 0; index < _needs.length; index++) ...[
                    _NeedCard(
                      need: _needs[index],
                      onView: () => _showNeed(context, _needs[index]),
                    ),
                    if (index < _needs.length - 1) const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: SizedBox(
            height: BuyerBottomNavigation.designHeight,
            child: FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: 440,
                height: BuyerBottomNavigation.designHeight,
                child: BuyerBottomNavigation(
                  activeTab: BuyerNavigationTab.home,
                  onHome: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  onPrimaryAction: () => _openNewNeed(context),
                  onReservations: () => Navigator.of(
                    context,
                  ).pushNamed(BuyerPurchasesPage.routeName),
                  onProfile: () => Navigator.of(
                    context,
                  ).pushNamed(BuyerProfilePage.routeName),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NeedsHeader extends StatelessWidget {
  const _NeedsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF087C2E),
      padding: const EdgeInsets.fromLTRB(47, 72, 30, 30),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mes demandes',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Suivez les réponses des producteurs',
            style: TextStyle(color: Color(0xFFE3F4E8), fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _NeedCard extends StatelessWidget {
  const _NeedCard({required this.need, required this.onView});

  final _BuyerNeed need;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final waiting = need.status == _NeedStatus.waiting;
    final statusColor =
        waiting ? const Color(0xFFF68A2F) : const Color(0xFF317D5F);
    final statusBackground =
        waiting ? const Color(0xFFFFF2E7) : const Color(0xFFE5F3EE);

    return Container(
      height: 146,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: need.accentColor, width: 1.2),
                ),
                child: ClipOval(
                  child: Image.asset(need.imageAsset, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      need.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${need.quantity} • ${need.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFA0AABB),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  need.proposals == 0
                      ? 'Aucune proposition'
                      : '${need.proposals} propositions',
                  style: const TextStyle(
                    color: Color(0xFFA0AABB),
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                width: 95,
                height: 25,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  waiting ? 'EN ATTENTE' : 'ACTIVE',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onView,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF07572F),
                padding: EdgeInsets.zero,
                minimumSize: const Size(58, 27),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Voir',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(width: 3),
                  Icon(Icons.chevron_right_rounded, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuyerNeed {
  const _BuyerNeed({
    required this.name,
    required this.quantity,
    required this.location,
    required this.proposals,
    required this.status,
    required this.imageAsset,
    required this.accentColor,
  });

  final String name;
  final String quantity;
  final String location;
  final int proposals;
  final _NeedStatus status;
  final String imageAsset;
  final Color accentColor;
}

const _needs = [
  _BuyerNeed(
    name: 'Tomate fraîche',
    quantity: '1 tonne',
    location: 'Dakar ou Thiès',
    proposals: 4,
    status: _NeedStatus.active,
    imageAsset: AppAssets.buyerTomato,
    accentColor: Color(0xFF86E9B3),
  ),
  _BuyerNeed(
    name: 'Oignon local',
    quantity: '500 kg',
    location: 'Dakar',
    proposals: 2,
    status: _NeedStatus.active,
    imageAsset: AppAssets.buyerOnion,
    accentColor: Color(0xFFA8CFFF),
  ),
  _BuyerNeed(
    name: 'Mangue Kent',
    quantity: '300 kg',
    location: 'Livraison souhaitée',
    proposals: 0,
    status: _NeedStatus.waiting,
    imageAsset: AppAssets.buyerCorn,
    accentColor: Color(0xFFF1B66E),
  ),
];
