import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../farmer_services/presentation/pages/farmer_services_pages.dart';
import '../../../harvest_publication/presentation/pages/harvest_publication_page.dart';
import '../../../harvests/presentation/pages/farmer_harvests_page.dart';
import '../../../home/presentation/pages/profile_home_page.dart';
import '../../../home/presentation/widgets/farmer_bottom_navigation.dart';
import '../../../home/presentation/widgets/farmer_glass_surface.dart';
import '../../../profile_selection/domain/entities/user_profile_type.dart';
import '../../../reservations/presentation/pages/reservations_received_page.dart';
import '../../../reviews/presentation/pages/reviews_reputation_page.dart';

class FarmerProfilePage extends StatelessWidget {
  const FarmerProfilePage({super.key});

  static const String routeName = '/farmer-profile';
  static const double _designWidth = 440;
  static const double _designHeight = 1120;
  static const double _navHeight = FarmerBottomNavigation.designHeight;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF18241D),
        body: LayoutBuilder(
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
                    const Positioned.fill(
                      child: FarmerGlassBackground(
                        assetPath: AppAssets.farmerProfileBackground,
                        overlayOpacity: 0.48,
                        blurSigma: 2,
                      ),
                    ),
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
                            child: _ProfileCanvas(
                              onNotification: () => Navigator.of(context)
                                  .pushNamed(NotificationsPage.routeName),
                              onHarvests: () => Navigator.of(context).pushNamed(
                                FarmerHarvestsPage.routeName,
                              ),
                              onReservations: () =>
                                  Navigator.of(context).pushNamed(
                                ReservationsReceivedPage.routeName,
                              ),
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
                        alignment: Alignment.bottomLeft,
                        child: SizedBox(
                          width: _designWidth,
                          height: _navHeight,
                          child: FarmerBottomNavigation(
                            activeTab: FarmerNavigationTab.profile,
                            onHome: () =>
                                Navigator.of(context).pushReplacementNamed(
                              ProfileHomePage.routeName,
                              arguments: UserProfileType.farmer,
                            ),
                            onHarvests: () => Navigator.of(context).pushNamed(
                              FarmerHarvestsPage.routeName,
                            ),
                            onPublishHarvest: () => Navigator.of(context)
                                .pushNamed(HarvestPublicationPage.routeName),
                            onReservations: () =>
                                Navigator.of(context).pushNamed(
                              ReservationsReceivedPage.routeName,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileCanvas extends StatelessWidget {
  const _ProfileCanvas({
    required this.onNotification,
    required this.onHarvests,
    required this.onReservations,
  });

  final VoidCallback onNotification;
  final VoidCallback onHarvests;
  final VoidCallback onReservations;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _ProfileTopBar(onNotification: onNotification),
        const Positioned(
          left: 0,
          right: 0,
          top: 104,
          child: _ProfileIdentity(),
        ),
        const Positioned(
          left: 20,
          right: 20,
          top: 316,
          height: 96,
          child: _ProfileStatsCard(),
        ),
        Positioned(
          left: 20,
          right: 20,
          top: 438,
          child: Column(
            children: [
              _ProfileMenuItem(
                icon: Icons.grass_rounded,
                label: 'Mes récoltes',
                onTap: onHarvests,
              ),
              _ProfileMenuItem(
                icon: Icons.event_available_outlined,
                label: 'Réservations reçues',
                onTap: onReservations,
              ),
              _ProfileMenuItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Paiements et retraits',
                onTap: () => Navigator.of(context).pushNamed(
                  PaymentsWithdrawalsPage.routeName,
                ),
              ),
              _ProfileMenuItem(
                icon: Icons.inventory_2_outlined,
                label: 'Mes besoins',
                onTap: () =>
                    Navigator.of(context).pushNamed(MyNeedsPage.routeName),
              ),
              _ProfileMenuItem(
                icon: Icons.reviews_outlined,
                label: 'Avis et réputation',
                onTap: () => Navigator.of(context).pushNamed(
                  ReviewsReputationPage.routeName,
                ),
              ),
              _ProfileMenuItem(
                icon: Icons.agriculture_outlined,
                label: 'Mon exploitation',
                onTap: () =>
                    Navigator.of(context).pushNamed(FarmPage.routeName),
              ),
              _ProfileMenuItem(
                icon: Icons.settings_outlined,
                label: 'Paramètres',
                onTap: () =>
                    Navigator.of(context).pushNamed(SettingsPage.routeName),
              ),
              _ProfileMenuItem(
                icon: Icons.help_outline_rounded,
                label: 'Aide et support',
                onTap: () => Navigator.of(context).pushNamed(
                  HelpSupportPage.routeName,
                ),
                hasBottomMargin: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({required this.onNotification});

  final VoidCallback onNotification;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      height: 74,
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
                onPressed: onNotification,
                icon: const Icon(
                  Icons.notifications_rounded,
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

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _ProfileAvatar(),
        SizedBox(height: 14),
        Text(
          'Ibrahima Mbaye',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 27,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_outlined,
              color: Color(0xFF76DB93),
              size: 17,
            ),
            SizedBox(width: 5),
            Text(
              'Agriculteur vérifié • Kaolack',
              style: TextStyle(
                color: Color(0xFF76DB93),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 112,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF92F8AD),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x52000000),
                    blurRadius: 18,
                    offset: Offset(0, 7),
                  ),
                ],
              ),
              child: const ClipOval(
                child: Image(
                  image: AssetImage(AppAssets.farmerProfile),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const Positioned(
            right: -1,
            bottom: 2,
            child: SizedBox.square(
              dimension: 25,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: AppColors.white, width: 2),
                  ),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: AppColors.white,
                  size: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatsCard extends StatelessWidget {
  const _ProfileStatsCard();

  @override
  Widget build(BuildContext context) {
    return FarmerGlassSurface(
      color: const Color(0x1AFFFFFF),
      blurSigma: 16,
      borderRadius: BorderRadius.circular(16),
      borderColor: const Color(0x33FFFFFF),
      boxShadow: const [
        BoxShadow(
          color: Color(0x26000000),
          blurRadius: 18,
          offset: Offset(0, 7),
        ),
      ],
      child: const Row(
        children: [
          Expanded(
            child: _ProfileStat(
              value: '24',
              label: 'Ventes',
              color: Color(0xFF92F8AD),
            ),
          ),
          _StatsDivider(),
          Expanded(
            child: _ProfileStat(
              value: '4,8',
              label: 'Note',
              color: Color(0xFFFF8A1F),
            ),
          ),
          _StatsDivider(),
          Expanded(
            child: _ProfileStat(
              value: '95%',
              label: 'Réponse',
              color: Color(0xFF92F8AD),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xCCFFFFFF),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatsDivider extends StatelessWidget {
  const _StatsDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 44,
      child: VerticalDivider(
        width: 1,
        thickness: 1,
        color: Color(0x33FFFFFF),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.hasBottomMargin = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool hasBottomMargin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: hasBottomMargin ? 10 : 0),
      child: SizedBox(
        height: 58,
        child: FarmerGlassSurface(
          color: const Color(0x0DFFFFFF),
          blurSigma: 8,
          borderRadius: BorderRadius.circular(14),
          borderColor: const Color(0x1AFFFFFF),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 31,
                      child: Icon(
                        icon,
                        color: const Color(0xFF92F8AD),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0x80FFFFFF),
                      size: 22,
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
