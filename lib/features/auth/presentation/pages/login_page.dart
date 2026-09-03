import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/auth_premium_surface.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/or_divider.dart';
import '../widgets/phone_number_field.dart';
import 'verification_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _phoneNumber = '';

  void _openVerification() {
    final nationalNumber = _phoneNumber.trim();
    Navigator.of(context).pushNamed(
      VerificationPage.routeName,
      arguments: nationalNumber.isEmpty
          ? VerificationPage.defaultPhoneNumber
          : '+221 $nationalNumber',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.forestDeep,
        body: Stack(
          children: [
            const Positioned.fill(
              child: AuthPremiumBackground(overlayOpacity: 0.18),
            ),
            SafeArea(
              child: _LoginContent(
                onPhoneChanged: (value) => _phoneNumber = value,
                onContinue: _openVerification,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginContent extends StatelessWidget {
  const _LoginContent({
    required this.onPhoneChanged,
    required this.onContinue,
  });

  final ValueChanged<String> onPhoneChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 760;
        final contentWidth = math.min(
          math.max(constraints.maxWidth - 24, 280.0),
          350.0,
        );

        return Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: SizedBox(
              width: contentWidth,
              child: AuthPremiumCard(
                color: const Color(0xA6102418),
                borderColor: const Color(0x66FFFFFF),
                padding: EdgeInsets.fromLTRB(
                  24,
                  isCompact ? 22 : 26,
                  24,
                  isCompact ? 22 : 26,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthBrandMark(onDark: true),
                    SizedBox(height: isCompact ? 18 : 22),
                    const _LoginHeader(),
                    SizedBox(height: isCompact ? 20 : 24),
                    PhoneNumberField(onChanged: onPhoneChanged),
                    const SizedBox(height: 12),
                    _ContinueButton(onPressed: onContinue),
                    SizedBox(height: isCompact ? 17 : 20),
                    const OrDivider(),
                    SizedBox(height: isCompact ? 14 : 16),
                    const GoogleSignInButton(),
                    SizedBox(height: isCompact ? 17 : 20),
                    const _LegalNotice(),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Bienvenue !',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Connectez-vous pour continuer',
          style: TextStyle(
            color: Color(0xFFDDE8E0),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.leaf,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Continuer'),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

class _LegalNotice extends StatelessWidget {
  const _LegalNotice();

  @override
  Widget build(BuildContext context) {
    const regular = TextStyle(
      color: Color(0xFFD3DED6),
      fontSize: 10,
      fontWeight: FontWeight.w500,
      height: 1.45,
    );
    const emphasized = TextStyle(
      color: AppColors.white,
      fontSize: 10,
      fontWeight: FontWeight.w800,
      height: 1.45,
    );

    return const Text.rich(
      TextSpan(
        style: regular,
        children: [
          TextSpan(text: 'En continuant, vous acceptez nos\n'),
          TextSpan(text: 'Conditions d’utilisation', style: emphasized),
          TextSpan(text: ' et notre '),
          TextSpan(text: 'Politique de\nconfidentialité.', style: emphasized),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
