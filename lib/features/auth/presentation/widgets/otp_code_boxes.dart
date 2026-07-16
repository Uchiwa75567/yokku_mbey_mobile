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
        const preferredGap = 23.0;
        final gap = constraints.maxWidth < 325 ? 16.0 : preferredGap;
        final boxWidth = ((constraints.maxWidth - (gap * 3)) / 4).clamp(
          56.0,
          64.0,
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (index) {
            final digit = index < code.length ? code[index] : '';

            return Padding(
              padding: EdgeInsets.only(
                right: index == 3 ? 0 : gap,
              ),
              child: SizedBox(
                width: boxWidth,
                height: 80,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    border: Border.fromBorderSide(
                      BorderSide(color: AppColors.border),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(11)),
                  ),
                  child: Center(
                    child: Text(
                      digit,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
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
