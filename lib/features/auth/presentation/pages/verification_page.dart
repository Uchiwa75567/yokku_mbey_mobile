import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile_selection/presentation/pages/profile_selection_page.dart';
import '../widgets/otp_code_boxes.dart';
import '../widgets/verification_keypad.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  static const String routeName = '/verification';
  static const Duration verificationSuccessDelay = Duration(milliseconds: 250);

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  static const int _otpLength = 4;

  String _otpCode = '';
  Timer? _successTimer;

  @override
  void dispose() {
    _successTimer?.cancel();
    super.dispose();
  }

  void _addDigit(String digit) {
    if (_otpCode.length >= _otpLength) {
      return;
    }

    final updatedCode = '$_otpCode$digit';
    setState(() => _otpCode = updatedCode);

    if (updatedCode.length == _otpLength) {
      _successTimer?.cancel();
      _successTimer = Timer(
        VerificationPage.verificationSuccessDelay,
        _openProfileSelection,
      );
    }
  }

  void _removeLastDigit() {
    if (_otpCode.isEmpty) {
      return;
    }

    _successTimer?.cancel();
    setState(() => _otpCode = _otpCode.substring(0, _otpCode.length - 1));
  }

  void _openProfileSelection() {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(ProfileSelectionPage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: _VerificationContent(
            code: _otpCode,
            onDigitPressed: _addDigit,
            onBackspacePressed: _removeLastDigit,
          ),
        ),
      ),
    );
  }
}

class _VerificationContent extends StatelessWidget {
  const _VerificationContent({
    required this.code,
    required this.onDigitPressed,
    required this.onBackspacePressed,
  });

  final String code;
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspacePressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 820;
        final contentWidth = math.min(constraints.maxWidth - 48, 390.0);
        final topGap = isCompact ? 34.0 : 58.0;
        final titleToDescriptionGap = isCompact ? 10.0 : 18.0;
        final descriptionToCodeGap = isCompact ? 22.0 : 34.0;
        final codeToResendGap = isCompact ? 22.0 : 34.0;
        final resendToKeypadGap = isCompact ? 22.0 : 42.0;

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: contentWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: topGap),
                    const Padding(
                      padding: EdgeInsets.only(left: 19),
                      child: Text(
                        'Entrez le code\nde vérification',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    SizedBox(height: titleToDescriptionGap),
                    const Padding(
                      padding: EdgeInsets.only(left: 19),
                      child: Text(
                        'Nous avons envoyé un code à\n+221 70 123 45 67',
                        style: TextStyle(
                          color: AppColors.softInk,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.55,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    SizedBox(height: descriptionToCodeGap),
                    Padding(
                      padding: const EdgeInsets.only(left: 19),
                      child: OtpCodeBoxes(code: code),
                    ),
                    SizedBox(height: codeToResendGap),
                    const Center(
                      child: Text(
                        'Renvoyer le code dans 00:45',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.softInk,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    SizedBox(height: resendToKeypadGap),
                    VerificationKeypad(
                      onDigitPressed: onDigitPressed,
                      onBackspacePressed: onBackspacePressed,
                    ),
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
