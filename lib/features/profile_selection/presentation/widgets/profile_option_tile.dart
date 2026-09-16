import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/profile_option.dart';

class ProfileOptionTile extends StatelessWidget {
  const ProfileOptionTile(
      {required this.option,
      required this.isSelected,
      required this.onTap,
      super.key});
  final ProfileOption option;
  final bool isSelected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Semantics(
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: isSelected ? AppColors.leafLight : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
                color: isSelected ? AppColors.leaf : AppColors.border,
                width: isSelected ? 1.5 : 1)),
        child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Icon(option.icon, color: option.color, size: 28),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(option.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              fontSize: 16)),
                      const SizedBox(height: 5),
                      Text(option.description,
                          style: const TextStyle(
                              color: AppColors.softInk, fontSize: 13)),
                    ])),
                const SizedBox(width: 10),
                Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? AppColors.leaf : AppColors.softInk,
                    size: 22),
              ]),
            )),
      ));
}
