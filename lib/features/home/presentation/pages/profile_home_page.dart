import 'package:flutter/material.dart';
import '../../../../core/data/marketplace_store.dart';
import '../../../profile_selection/domain/entities/user_profile_type.dart';
import '../../../stakeholders/presentation/pages/stakeholder_pages.dart';
import 'buyer_home_page.dart';
import 'farmer_home_page.dart';

class ProfileHomePage extends StatelessWidget {
  const ProfileHomePage({required this.profileType, super.key});
  static const String routeName = '/home';
  final UserProfileType profileType;
  static ProfileHomePage fromRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    return ProfileHomePage(
        profileType: MarketplaceScope.maybeOf(context)?.role ??
            (args is UserProfileType ? args : UserProfileType.farmer));
  }

  @override
  Widget build(BuildContext context) => switch (profileType) {
        UserProfileType.farmer => const FarmerHomePage(),
        UserProfileType.buyer => const BuyerHomePage(),
        _ => const StakeholderHomePage(),
      };
}
