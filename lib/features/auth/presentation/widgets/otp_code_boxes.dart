import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class OtpCodeBoxes extends StatelessWidget {
  const OtpCodeBoxes({
    required this.code,
    super.key,
  });

  final String code;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const preferredGap = 10.0;
        final gap = constraints.maxWidth < 260 ? 8.0 : preferredGap;
        final boxWidth = ((constraints.maxWidth - (gap * 3)) / 4).clamp(
          48.0,
          56.0,
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (index) {
            final digit = index < code.length ? code[index] : '';
            final isFilled = digit.isNotEmpty;
            final isActive = index == code.length && code.length < 4;

            return Padding(
              padding: EdgeInsets.only(
                right: index == 3 ? 0 : gap,
              ),
              child: Semantics(
                label: 'Chiffre ${index + 1} du code',
                value: isFilled ? digit : 'vide',
                child: SizedBox(
                  width: boxWidth,
                  height: 56,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color:
                          isFilled ? AppColors.surfaceGreen : AppColors.white,
                      border: Border.all(
                        color: isFilled || isActive
                            ? AppColors.leaf
                            : AppColors.border,
                        width: isActive ? 1.8 : 1.2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.leaf.withValues(alpha: 0.12),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 120),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Text(
                          digit,
                          key: ValueKey('$index-$digit'),
                          style: const TextStyle(
                            color: AppColors.forestDeep,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
