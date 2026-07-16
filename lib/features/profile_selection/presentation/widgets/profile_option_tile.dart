import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/profile_option.dart';

class ProfileOptionTile extends StatelessWidget {
  const ProfileOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final ProfileOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isSelected ? const Color(0xFF74E09B) : Colors.transparent;
    final foregroundColor = isSelected ? AppColors.leaf : AppColors.inputHint;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: isSelected ? 91 : 88,
        padding: const EdgeInsets.fromLTRB(16, 15, 15, 15),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.selectedOptionBackground
              : AppColors.optionBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            _ProfileIcon(option: option),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    option.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.softInk,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.15,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: foregroundColor,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileIcon extends StatelessWidget {
  const _ProfileIcon({required this.option});

  final ProfileOption option;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: option.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          option.icon,
          color: option.color,
          size: 29,
        ),
      ),
    );
  }
}
