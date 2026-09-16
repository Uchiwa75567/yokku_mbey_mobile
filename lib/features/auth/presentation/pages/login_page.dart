import 'package:flutter/material.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/data/marketplace_store.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../core/widgets/journey_scaffold.dart';
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
    final number = '+221 $nationalNumber';
    try {
      final store = MarketplaceScope.maybeOf(context);
      if (store != null) {
        store.requestCode(number);
      } else if (!RegExp(r'^7[05678]\d{7}$')
          .hasMatch(nationalNumber.replaceAll(' ', ''))) {
        throw const BusinessException(
            'Saisissez un numéro mobile sénégalais valide.');
      }
    } on BusinessException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    Navigator.of(context)
        .pushNamed(VerificationPage.routeName, arguments: number);
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
                aspectRatio: 2,
                child:
                    Image.asset(AppAssets.buyerHomeTomato, fit: BoxFit.cover))),
        const SizedBox(height: 28),
        Text('Bienvenue !', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text('Connectez-vous pour continuer',
            style: TextStyle(color: AppColors.softInk, fontSize: 16)),
        const SizedBox(height: 28),
        const Text('Numéro de téléphone',
            style:
                TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink)),
        const SizedBox(height: 10),
        PhoneNumberField(onChanged: (v) => _phoneNumber = v),
        const SizedBox(height: 20),
        FilledButton.icon(
            onPressed: _openVerification,
            icon: const Icon(Icons.arrow_forward, size: 20),
            label: const Text('Continuer')),
        const SizedBox(height: 24),
        const JourneyNotice(
            'Mode démonstration · code 1234\nAucun SMS réel ne sera envoyé.'),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        const Text(
            'Votre numéro permet de retrouver vos données sur cet appareil.',
            style:
                TextStyle(color: AppColors.softInk, fontSize: 12, height: 1.5)),
      ]);
}
