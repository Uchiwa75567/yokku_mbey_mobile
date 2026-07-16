import 'package:flutter/material.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.fromBorderSide(
            BorderSide(color: AppColors.border),
          ),
          borderRadius: BorderRadius.all(Radius.circular(11)),
        ),
        child: Row(
          children: [
            _CountryCode(),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.border,
            ),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 18),
                  hintText: '70 123 45 67',
                  hintStyle: TextStyle(
                    color: AppColors.inputHint,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                ),
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryCode extends StatelessWidget {
  const _CountryCode();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 97,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SenegalFlag(),
          SizedBox(width: 10),
          Text(
            '+221',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SenegalFlag extends StatelessWidget {
  const _SenegalFlag();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Image.asset(
        AppAssets.senegalFlag,
        width: 20,
        height: 16,
        fit: BoxFit.cover,
      ),
    );
  }
}
