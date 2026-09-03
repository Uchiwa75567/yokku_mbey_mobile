import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile_selection/presentation/pages/profile_selection_page.dart';
import '../widgets/auth_premium_surface.dart';
import '../widgets/otp_code_boxes.dart';
import '../widgets/verification_keypad.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({
    super.key,
    this.phoneNumber = defaultPhoneNumber,
  });

  static const String routeName = '/verification';
  static const String defaultPhoneNumber = '+221 70 123 45 67';
  static const Duration verificationSuccessDelay = Duration(milliseconds: 250);

  final String phoneNumber;

  static VerificationPage fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return VerificationPage(
      phoneNumber: arguments is String && arguments.trim().isNotEmpty
          ? arguments
          : defaultPhoneNumber,
    );
  }

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  static const int _otpLength = 4;

  String _otpCode = '';
  bool _isVerifying = false;
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
    setState(() {
      _otpCode = updatedCode;
      _isVerifying = updatedCode.length == _otpLength;
    });

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
    setState(() {
      _otpCode = _otpCode.substring(0, _otpCode.length - 1);
      _isVerifying = false;
    });
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
        backgroundColor: AppColors.forestDeep,
        body: Stack(
          children: [
            const Positioned.fill(
              child: AuthPremiumBackground(overlayOpacity: 0.24),
            ),
            SafeArea(
              child: _VerificationContent(
                code: _otpCode,
                phoneNumber: widget.phoneNumber,
                isVerifying: _isVerifying,
                onDigitPressed: _addDigit,
                onBackspacePressed: _removeLastDigit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationContent extends StatelessWidget {
  const _VerificationContent({
    required this.code,
    required this.phoneNumber,
    required this.isVerifying,
    required this.onDigitPressed,
    required this.onBackspacePressed,
  });

  final String code;
  final String phoneNumber;
  final bool isVerifying;
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspacePressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 780;
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
                color: const Color(0xB30E2117),
                borderColor: const Color(0x66FFFFFF),
                padding: EdgeInsets.fromLTRB(
                  18,
                  isCompact ? 18 : 22,
                  18,
                  isCompact ? 16 : 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _VerificationHeader(),
                    SizedBox(height: isCompact ? 13 : 17),
                    const _SecurityMark(),
                    const SizedBox(height: 14),
                    const Text(
                      'Entrez le code de\nvérification',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                        letterSpacing: -0.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nous avons envoyé un code à $phoneNumber',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFD8E4DB),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: isCompact ? 18 : 22),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: OtpCodeBoxes(code: code),
                    ),
                    const SizedBox(height: 17),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: isVerifying
                          ? const _VerifyingStatus(key: ValueKey('verifying'))
                          : const Text(
                              'Renvoyer le code dans 00:45',
                              key: ValueKey('resend'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFD8E4DB),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                    SizedBox(height: isCompact ? 15 : 20),
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

class _VerificationHeader extends StatelessWidget {
  const _VerificationHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox.square(
              dimension: 34,
              child: IconButton(
                tooltip: 'Retour',
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(context).maybePop(),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0x33FFFFFF),
                  foregroundColor: AppColors.white,
                  side: const BorderSide(color: Color(0x55FFFFFF)),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
              ),
            ),
          ),
          const AuthBrandMark(compact: true, onDark: true),
        ],
      ),
    );
  }
}

class _SecurityMark extends StatelessWidget {
  const _SecurityMark();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox.square(
        dimension: 50,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.leafLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_outline_rounded,
            color: AppColors.leaf,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _VerifyingStatus extends StatelessWidget {
  const _VerifyingStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox.square(
          dimension: 15,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.leaf,
          ),
        ),
        SizedBox(width: 9),
        Flexible(
          child: Text(
            'Vérification en cours…',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(0xFFB9F2C8),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
