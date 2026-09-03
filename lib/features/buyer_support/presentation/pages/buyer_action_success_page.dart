import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class BuyerActionSuccessArguments {
  const BuyerActionSuccessArguments({
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.destinationRoute,
    this.icon = Icons.check_rounded,
  });
  final String title;
  final String message;
  final String buttonLabel;
  final String destinationRoute;
  final IconData icon;
}

class BuyerActionSuccessPage extends StatelessWidget {
  const BuyerActionSuccessPage({super.key, required this.arguments});
  static const routeName = '/buyer-action-success';
  final BuyerActionSuccessArguments arguments;

  static Widget fromRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    return BuyerActionSuccessPage(
      arguments: args is BuyerActionSuccessArguments
          ? args
          : const BuyerActionSuccessArguments(
              title: 'Opération réussie',
              message: 'Votre action a bien été enregistrée.',
              buttonLabel: 'Terminer',
              destinationRoute: '/',
            ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(0xFF08713B),
                  child: Icon(arguments.icon, color: Colors.white, size: 52),
                ),
                const SizedBox(height: 30),
                Text(
                  arguments.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  arguments.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF697386),
                    fontSize: 16,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 52),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamedAndRemoveUntil(
                    arguments.destinationRoute,
                    (route) => route.isFirst,
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                    backgroundColor: const Color(0xFF076735),
                  ),
                  child: Text(arguments.buttonLabel),
                ),
              ],
            ),
          ),
        ),
      );
}
