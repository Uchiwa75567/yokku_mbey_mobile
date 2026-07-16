import 'package:flutter/material.dart';

import 'user_profile_type.dart';

class ProfileOption {
  const ProfileOption({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final UserProfileType type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
}
