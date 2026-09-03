import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'farmer_glass_surface.dart';

enum FarmerNavigationTab { home, harvests, reservations, profile }

class FarmerBottomNavigation extends StatelessWidget {
  const FarmerBottomNavigation({
    super.key,
    required this.activeTab,
    required this.onPublishHarvest,
    this.onHome,
    this.onHarvests,
    this.onReservations,
    this.onProfile,
  });

  static const double designHeight = 80;

  final FarmerNavigationTab activeTab;
  final VoidCallback onPublishHarvest;
  final VoidCallback? onHome;
  final VoidCallback? onHarvests;
  final VoidCallback? onReservations;
  final VoidCallback? onProfile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: designHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(
            child: FarmerGlassSurface(
              color: Color(0xE6FFFFFF),
              blurSigma: 20,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              borderColor: Color(0x66FFFFFF),
              boxShadow: [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 24,
                  offset: Offset(0, -4),
                ),
              ],
              child: SizedBox.expand(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _FarmerBottomNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Accueil',
                isActive: activeTab == FarmerNavigationTab.home,
                onTap: onHome,
              ),
              _FarmerBottomNavItem(
                icon: Icons.grass_outlined,
                activeIcon: Icons.grass_rounded,
                label: 'Récoltes',
                isActive: activeTab == FarmerNavigationTab.harvests,
                onTap: onHarvests,
              ),
              const SizedBox(width: 58),
              _FarmerBottomNavItem(
                icon: Icons.event_available_outlined,
                activeIcon: Icons.event_available_rounded,
                label: 'Réservations',
                isActive: activeTab == FarmerNavigationTab.reservations,
                onTap: onReservations,
              ),
              _FarmerBottomNavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profil',
                isActive: activeTab == FarmerNavigationTab.profile,
                onTap: onProfile,
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            top: -18,
            child: Semantics(
              button: true,
              label: 'Publier une récolte',
              child: Center(
                child: GestureDetector(
                  onTap: onPublishHarvest,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFF006131),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.72),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF004722).withValues(alpha: 0.40),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmerBottomNavItem extends StatelessWidget {
  const _FarmerBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF006131) : const Color(0xFF59655E);

    return SizedBox(
      width: 80,
      child: Material(
        color: isActive
            ? const Color(0xFF006131).withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isActive ? activeIcon : icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
