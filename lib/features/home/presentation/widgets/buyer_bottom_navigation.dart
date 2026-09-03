import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

enum BuyerNavigationTab { home, search, reservations, profile }

class BuyerBottomNavigation extends StatelessWidget {
  const BuyerBottomNavigation({
    required this.activeTab,
    super.key,
    this.onHome,
    this.onSearch,
    this.onReservations,
    this.onProfile,
    this.onPrimaryAction,
  });

  static const double designHeight = 74;

  final BuyerNavigationTab activeTab;
  final VoidCallback? onHome;
  final VoidCallback? onSearch;
  final VoidCallback? onReservations;
  final VoidCallback? onProfile;
  final VoidCallback? onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: SizedBox(
        height: designHeight,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BuyerNavItem(
                    icon: Icons.home,
                    label: 'Accueil',
                    isActive: activeTab == BuyerNavigationTab.home,
                    onTap: onHome,
                  ),
                  _BuyerNavItem(
                    icon: Icons.storefront_outlined,
                    label: 'Recherche',
                    isActive: activeTab == BuyerNavigationTab.search,
                    onTap: onSearch,
                  ),
                  const SizedBox(width: 56),
                  _BuyerNavItem(
                    icon: Icons.shopping_basket_outlined,
                    label: 'Réservations',
                    isActive: activeTab == BuyerNavigationTab.reservations,
                    onTap: onReservations,
                  ),
                  _BuyerNavItem(
                    icon: Icons.person_outline,
                    label: 'Profil',
                    isActive: activeTab == BuyerNavigationTab.profile,
                    onTap: onProfile,
                  ),
                ],
              ),
              Positioned(
                left: 167,
                top: -15,
                child: Semantics(
                  button: true,
                  label: 'Action principale',
                  child: GestureDetector(
                    onTap: onPrimaryAction,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFBBF7D0,
                            ).withValues(alpha: 0.9),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuyerNavItem extends StatelessWidget {
  const _BuyerNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF4CAF50) : const Color(0xFF9CA3AF);

    return SizedBox(
      width: 62,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w400,
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
