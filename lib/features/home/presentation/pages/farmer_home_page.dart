import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../farmer_services/presentation/pages/farmer_services_pages.dart';
import '../../../harvest_publication/presentation/pages/harvest_publication_page.dart';
import '../../../harvests/presentation/pages/farmer_harvests_page.dart';
import '../../../profile/presentation/pages/farmer_profile_page.dart';
import '../../../reservations/presentation/pages/reservations_received_page.dart';
import '../widgets/farmer_bottom_navigation.dart';
import '../widgets/farmer_glass_surface.dart';

class FarmerHomePage extends StatelessWidget {
  const FarmerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Color(0xFF18241D),
        body: _FarmerHomeContent(),
      ),
    );
  }
}

class _FarmerHomeContent extends StatelessWidget {
  const _FarmerHomeContent();

  static const double _designWidth = 440;
  static const double _designHeight = 1130;
  static const double _navHeight = FarmerBottomNavigation.designHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / _designWidth).clamp(0.1, 1.0);
        final width = _designWidth * scale;
        final height = _designHeight * scale;
        final navHeight = _navHeight * scale;
        final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

        return Center(
          child: SizedBox(
            width: width,
            height: constraints.maxHeight,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: navHeight + bottomInset + 18,
                  ),
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: _designWidth,
                        height: _designHeight,
                        child: _FarmerHomeCanvas(
                          onPublishHarvest: () => Navigator.of(context)
                              .pushNamed(HarvestPublicationPage.routeName),
                          onNotifications: () => Navigator.of(context)
                              .pushNamed(NotificationsPage.routeName),
                          onWantedProducts: () => Navigator.of(context)
                              .pushNamed(WantedProductsPage.routeName),
                          onNeeds: () => Navigator.of(context)
                              .pushNamed(MyNeedsPage.routeName),
                          onOpportunities: () => Navigator.of(context)
                              .pushNamed(OpportunitiesPage.routeName),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: bottomInset,
                  height: navHeight,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: SizedBox(
                      width: _designWidth,
                      height: _navHeight,
                      child: FarmerBottomNavigation(
                        activeTab: FarmerNavigationTab.home,
                        onPublishHarvest: () => Navigator.of(context)
                            .pushNamed(HarvestPublicationPage.routeName),
                        onHarvests: () => Navigator.of(context)
                            .pushNamed(FarmerHarvestsPage.routeName),
                        onReservations: () => Navigator.of(context)
                            .pushNamed(ReservationsReceivedPage.routeName),
                        onProfile: () => Navigator.of(context)
                            .pushNamed(FarmerProfilePage.routeName),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FarmerHomeCanvas extends StatelessWidget {
  const _FarmerHomeCanvas({
    required this.onPublishHarvest,
    required this.onNotifications,
    required this.onWantedProducts,
    required this.onNeeds,
    required this.onOpportunities,
  });

  final VoidCallback onPublishHarvest;
  final VoidCallback onNotifications;
  final VoidCallback onWantedProducts;
  final VoidCallback onNeeds;
  final VoidCallback onOpportunities;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: FarmerGlassBackground(overlayOpacity: 0.42),
        ),
        _TopBar(onNotifications: onNotifications),
        const _BalanceCard(),
        const _StatsGrid(),
        const _HarvestReminder(),
        _QuickActions(
          onPublishHarvest: onPublishHarvest,
          onWantedProducts: onWantedProducts,
          onNeeds: onNeeds,
          onOpportunities: onOpportunities,
        ),
        const _LatestReservation(),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onNotifications});

  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      height: 66,
      child: FarmerGlassSurface(
        color: const Color(0x1AFFFFFF),
        blurSigma: 16,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(26),
        ),
        borderColor: const Color(0x33FFFFFF),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const SizedBox.square(
                dimension: 32,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0x33FFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.eco_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Yokku Mbey',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Notifications',
                onPressed: onNotifications,
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 18,
      right: 18,
      top: 86,
      height: 124,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 17, 18, 15),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDDEBE1)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF173C28).withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solde disponible',
                  style: TextStyle(
                    color: Color(0xFF6C756F),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '1 250 000 FCFA',
                  style: TextStyle(
                    color: Color(0xFF073E22),
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                Spacer(),
                Text(
                  'Disponible après les ventes validées',
                  style: TextStyle(
                    color: Color(0xFF7B857E),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Positioned(
              right: -12,
              top: -9,
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F5F1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Color(0xFFB9C9BE),
                  size: 38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      left: 18,
      right: 18,
      top: 232,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.eco_outlined,
                  label: 'Récoltes actives',
                  value: '12',
                  color: Color(0xFF147D40),
                  tint: Color(0xFFE6F5E9),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _StatCard(
                  icon: Icons.event_available_outlined,
                  label: 'Réservations reçues',
                  value: '18',
                  color: Color(0xFF35514A),
                  tint: Color(0xFFE7F1ED),
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.shopping_cart_checkout_outlined,
                  label: 'Ventes réalisées',
                  value: '320',
                  color: Color(0xFFE45D24),
                  tint: Color(0xFFFFEADF),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _StatCard(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Paiements en attente',
                  value: '24',
                  color: Color(0xFF7B2CE6),
                  tint: Color(0xFFF1E5FF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 102,
      padding: const EdgeInsets.fromLTRB(16, 13, 12, 11),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.86)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF173C28).withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF17251D),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF5F6963),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1.15,
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

class _HarvestReminder extends StatelessWidget {
  const _HarvestReminder();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 18,
      right: 18,
      top: 458,
      height: 52,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE9F4EC).withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: const Color(0xFFC7DDCC)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF315B40), size: 18),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '2 récoltes bientôt disponibles',
                style: TextStyle(
                  color: Color(0xFF4B5D51),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onPublishHarvest,
    required this.onWantedProducts,
    required this.onNeeds,
    required this.onOpportunities,
  });

  final VoidCallback onPublishHarvest;
  final VoidCallback onWantedProducts;
  final VoidCallback onNeeds;
  final VoidCallback onOpportunities;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 18,
      right: 18,
      top: 548,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions rapides',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QuickAction(
                icon: Icons.add_circle_outline,
                label: 'Ajouter\nune récolte',
                onTap: onPublishHarvest,
              ),
              _QuickAction(
                icon: Icons.search_rounded,
                label: 'Produits\nrecherchés',
                onTap: onWantedProducts,
              ),
              _QuickAction(
                icon: Icons.receipt_long_outlined,
                label: 'Mes besoins',
                onTap: onNeeds,
              ),
              _QuickAction(
                icon: Icons.trending_up_rounded,
                label: 'Opportunités',
                onTap: onOpportunities,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Column(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(icon, color: const Color(0xFF263D30), size: 25),
              ),
              const SizedBox(height: 9),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestReservation extends StatelessWidget {
  const _LatestReservation();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 18,
      right: 18,
      top: 736,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dernière réservation',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            height: 112,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF173C28).withValues(alpha: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    AppAssets.farmerTomatoHarvest,
                    width: 92,
                    height: 92,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tomates fraîches',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF18251D),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '500 kg',
                        style: TextStyle(
                          color: Color(0xFF6E7872),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _ReservationStatus(),
                    SizedBox(height: 14),
                    Text(
                      '150 000 F',
                      style: TextStyle(
                        color: Color(0xFF315B40),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationStatus extends StatelessWidget {
  const _ReservationStatus();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF5E5),
        borderRadius: BorderRadius.circular(99),
      ),
      child: const Text(
        'ACCEPTÉE',
        style: TextStyle(
          color: Color(0xFF238044),
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
