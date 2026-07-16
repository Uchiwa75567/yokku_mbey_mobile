import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/or_divider.dart';
import '../widgets/phone_number_field.dart';
import 'verification_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: _LoginContent(),
        ),
      ),
    );
  }
}

class _LoginContent extends StatelessWidget {
  const _LoginContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 700;
        final contentWidth = math.min(constraints.maxWidth, 390.0);

        return Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  42,
                  isCompact ? 54 : 96,
                  50,
                  isCompact ? 24 : 34,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _LoginHeader(),
                    SizedBox(height: isCompact ? 44 : 86),
                    const Text(
                      'Téléphone',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const PhoneNumberField(),
                    SizedBox(height: isCompact ? 24 : 32),
                    const _ContinueButton(),
                    SizedBox(height: isCompact ? 48 : 88),
                    const OrDivider(),
                    SizedBox(height: isCompact ? 24 : 36),
                    const GoogleSignInButton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bienvenue !',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 18),
        Text(
          'Connectez-vous pour continuer',
          style: TextStyle(
            color: AppColors.softInk,
            fontSize: 18,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: FilledButton(
        onPressed: () {
          Navigator.of(context).pushNamed(VerificationPage.routeName);
        },
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.leaf,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        child: const Text('Continuer'),
      ),
    );
  }
}
