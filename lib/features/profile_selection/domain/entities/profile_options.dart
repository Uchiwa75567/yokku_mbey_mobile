import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'profile_option.dart';
import 'user_profile_type.dart';

abstract final class ProfileOptions {
  static const int defaultSelectedIndex = 2;

  static const List<ProfileOption> items = [
    ProfileOption(
      type: UserProfileType.farmer,
      title: 'Agriculteur',
      description: 'Je vends mes récoltes',
      icon: Icons.person_outline,
      color: AppColors.leaf,
      backgroundColor: AppColors.greenSoft,
    ),
    ProfileOption(
      type: UserProfileType.buyer,
      title: 'Acheteur',
      description: "J'achète des produits",
      icon: Icons.shopping_bag_outlined,
      color: AppColors.orange,
      backgroundColor: AppColors.orangeSoft,
    ),
    ProfileOption(
      type: UserProfileType.provider,
      title: 'Prestataire',
      description: 'Je fournis des services',
      icon: Icons.hub_outlined,
      color: AppColors.leaf,
      backgroundColor: AppColors.greenSoft,
    ),
    ProfileOption(
      type: UserProfileType.investor,
      title: 'Investisseur / ONG',
      description: 'Je finance des projets',
      icon: Icons.trending_up,
      color: AppColors.blue,
      backgroundColor: AppColors.blueSoft,
    ),
  ];
}
