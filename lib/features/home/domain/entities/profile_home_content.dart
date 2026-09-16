import 'package:flutter/material.dart';

import '../../../profile_selection/domain/entities/user_profile_type.dart';

class ProfileHomeContent {
  const ProfileHomeContent({
    required this.profileType,
    required this.title,
    required this.subtitle,
    required this.guidanceTitle,
    required this.guidanceText,
    required this.actions,
  });

  final UserProfileType profileType;
  final String title;
  final String subtitle;
  final String guidanceTitle;
  final String guidanceText;
  final List<ProfileHomeAction> actions;
}

class ProfileHomeAction {
  const ProfileHomeAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.routeName,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String? routeName;
}
