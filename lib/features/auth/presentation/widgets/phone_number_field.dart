import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    super.key,
    this.controller,
    this.onChanged,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.telephoneNumberNational],
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
          LengthLimitingTextInputFormatter(12),
        ],
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.white,
          prefixIcon: const _CountryCode(),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 102,
            minHeight: 50,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          hintText: '77 000 00 00',
          hintStyle: const TextStyle(
            color: AppColors.inputHint,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.leaf, width: 1.6),
          ),
        ),
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 14,
          fontWeight: FontWeight.w700,
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
      width: 102,
      child: Row(
        children: [
          SizedBox(width: 11),
          _SenegalFlag(),
          SizedBox(width: 7),
          Text(
            '+221',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          Spacer(),
          SizedBox(
            height: 24,
            child: VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.border,
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
        width: 19,
        height: 15,
        fit: BoxFit.cover,
      ),
    );
  }
}
