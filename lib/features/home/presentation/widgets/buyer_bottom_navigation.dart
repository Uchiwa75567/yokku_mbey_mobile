import 'package:flutter/material.dart';
import 'farmer_bottom_navigation.dart';

enum BuyerNavigationTab { home, search, reservations, profile }

class BuyerBottomNavigation extends StatelessWidget {
  const BuyerBottomNavigation(
      {required this.activeTab,
      super.key,
      this.onHome,
      this.onSearch,
      this.onReservations,
      this.onProfile,
      this.onPrimaryAction});
  static const double designHeight = FarmerBottomNavigation.designHeight;
  final BuyerNavigationTab activeTab;
  final VoidCallback? onHome,
      onSearch,
      onReservations,
      onProfile,
      onPrimaryAction;
  @override
  Widget build(BuildContext context) => FarmerBottomNavigation(
        activeTab: FarmerNavigationTab.values[activeTab.index],
        onHome: onHome,
        onHarvests: onSearch,
        onReservations: onReservations,
        onProfile: onProfile,
        onPublishHarvest: onPrimaryAction ?? () {},
        secondLabel: 'Marché',
        secondIcon: Icons.search,
        secondActiveIcon: Icons.search,
        thirdLabel: 'Achats',
        thirdIcon: Icons.shopping_basket_outlined,
        thirdActiveIcon: Icons.shopping_basket,
        actionLabel: 'Publier une demande',
      );
}
