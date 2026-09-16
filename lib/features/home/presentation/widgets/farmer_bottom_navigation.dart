import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
    this.secondLabel = 'Récoltes',
    this.thirdLabel = 'Réservations',
    this.secondIcon = Icons.grass_outlined,
    this.secondActiveIcon = Icons.grass_rounded,
    this.thirdIcon = Icons.event_available_outlined,
    this.thirdActiveIcon = Icons.event_available_rounded,
    this.actionLabel = 'Publier une récolte',
  });
  static const double designHeight = 76;
  final FarmerNavigationTab activeTab;
  final VoidCallback onPublishHarvest;
  final VoidCallback? onHome, onHarvests, onReservations, onProfile;
  final String secondLabel, thirdLabel, actionLabel;
  final IconData secondIcon, secondActiveIcon, thirdIcon, thirdActiveIcon;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.border))),
        child: SizedBox(
            height: designHeight,
            child: Row(children: [
              _item('Accueil', Icons.home_outlined, Icons.home_rounded, 0,
                  onHome),
              _item(secondLabel, secondIcon, secondActiveIcon, 1, onHarvests),
              SizedBox(
                  width: 60,
                  child: Center(
                      child: SizedBox.square(
                          dimension: 48,
                          child: Semantics(
                              label: actionLabel,
                              button: true,
                              onTap: onPublishHarvest,
                              child: ExcludeSemantics(
                                  child: IconButton.filled(
                                tooltip: actionLabel,
                                onPressed: onPublishHarvest,
                                style: IconButton.styleFrom(
                                    backgroundColor: AppColors.leaf,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8))),
                                icon: const Icon(Icons.add, size: 28),
                              )))))),
              _item(thirdLabel, thirdIcon, thirdActiveIcon, 2, onReservations),
              _item('Profil', Icons.person_outline, Icons.person, 3, onProfile),
            ])),
      );

  Widget _item(String label, IconData icon, IconData selectedIcon, int index,
      VoidCallback? onTap) {
    final selected = activeTab.index == index;
    final color = selected ? AppColors.leaf : AppColors.mutedInk;
    return Expanded(
        child: Semantics(
            selected: selected,
            child: Material(
              color: Colors.white,
              child: InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(selected ? selectedIcon : icon,
                              color: color, size: 23),
                          const SizedBox(height: 4),
                          Text(label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: color,
                                  letterSpacing: 0)),
                        ]),
                  )),
            )));
  }
}
