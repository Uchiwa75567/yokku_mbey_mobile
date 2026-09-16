import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/data/marketplace_store.dart';
import '../../../home/presentation/pages/profile_home_page.dart';
import '../../../profile_selection/presentation/pages/profile_selection_page.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../core/widgets/journey_scaffold.dart';
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
  Timer? _resendTimer;
  int _resendSeconds = 60;

  @override
  void initState() {
    super.initState();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _resendSeconds > 0) setState(() => _resendSeconds--);
    });
  }

  void _resend() {
    try {
      MarketplaceScope.maybeOf(context)?.requestCode(widget.phoneNumber);
      setState(() {
        _resendSeconds = 60;
        _otpCode = '';
        _isVerifying = false;
      });
    } on BusinessException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  void dispose() {
    _successTimer?.cancel();
    _resendTimer?.cancel();
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
        _completeVerification,
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

  void _completeVerification() {
    if (!mounted) {
      return;
    }

    try {
      final store = MarketplaceScope.maybeOf(context);
      if (store != null) {
        store.verifyCode(_otpCode);
      } else if (_otpCode != '1234') {
        throw const BusinessException(
            'Code incorrect. Le code de démonstration est 1234.');
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      if (store?.signedIn ?? false) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            ProfileHomePage.routeName, (_) => false,
            arguments: store!.role);
      } else {
        Navigator.of(context)
            .pushReplacementNamed(ProfileSelectionPage.routeName);
      }
    } on BusinessException catch (e) {
      setState(() {
        _otpCode = '';
        _isVerifying = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(back: true, children: [
        const Align(
            alignment: Alignment.centerLeft,
            child: CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.leafLight,
                child:
                    Icon(Icons.sms_outlined, color: AppColors.leaf, size: 28))),
        const SizedBox(height: 24),
        Text('Entrez le code de vérification',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Text('Compte : ${widget.phoneNumber}',
            style: const TextStyle(color: AppColors.softInk)),
        const SizedBox(height: 24),
        const JourneyNotice(
            'Démonstration : saisissez 1234. Aucun SMS envoyé.'),
        const SizedBox(height: 28),
        Center(child: OtpCodeBoxes(code: _otpCode)),
        const SizedBox(height: 16),
        SizedBox(
            height: 48,
            child: Center(
                child: _isVerifying
                    ? const Row(mainAxisSize: MainAxisSize.min, children: [
                        SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 12),
                        Flexible(child: Text('Vérification en cours…')),
                      ])
                    : TextButton(
                        onPressed: _resendSeconds == 0 ? _resend : null,
                        child: Text(_resendSeconds == 0
                            ? 'Renvoyer le code'
                            : 'Renvoyer dans ${_resendSeconds}s')))),
        const SizedBox(height: 20),
        Center(
            child: VerificationKeypad(
                onDigitPressed: _addDigit,
                onBackspacePressed: _removeLastDigit)),
        const SizedBox(height: 24),
        TextButton.icon(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Modifier mon numéro')),
      ]);
}
