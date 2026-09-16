import 'package:flutter/material.dart';
import '../../../../core/data/marketplace_store.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/widgets/journey_scaffold.dart';

class FarmerProfilePage extends StatelessWidget {
  const FarmerProfilePage({super.key});
  static const String routeName = '/farmer-profile';
  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.maybeOf(context);
    return JourneyScaffold(title: 'Mon profil', root: true, tab: 3, children: [
      Row(children: [
        const CircleAvatar(
            radius: 30, backgroundImage: AssetImage(AppAssets.farmerProfile)),
        const SizedBox(width: 16),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(store?.name ?? 'Mon compte',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(store?.phone ?? 'Agriculteur',
              style: const TextStyle(color: journeyMuted)),
        ])),
      ]),
      const Divider(),
      for (final item in <(IconData, String, String)>[
        (Icons.swap_horiz_rounded, 'Changer d’espace', '/profile-selection'),
        (
          Icons.badge_outlined,
          'Informations personnelles',
          '/account-personal'
        ),
        (Icons.grass_outlined, 'Mes récoltes', '/farmer-harvests'),
        (
          Icons.inventory_2_outlined,
          'Réservations reçues',
          '/reservations-received'
        ),
        (
          Icons.account_balance_wallet_outlined,
          'Paiements et retraits',
          '/payments-withdrawals'
        ),
        (Icons.agriculture_outlined, 'Mon exploitation', '/my-farm'),
        (Icons.assignment_outlined, 'Mes besoins', '/my-needs'),
        (Icons.agriculture_outlined, 'Travail et matériel', '/farmer-services'),
        (
          Icons.work_outline,
          'Mes demandes de prestation',
          '/farmer-service-requests'
        ),
        (Icons.star_outline, 'Avis et réputation', '/reviews-reputation'),
        (Icons.settings_outlined, 'Paramètres', '/settings'),
        (Icons.help_outline, 'Aide et support', '/help-support'),
      ])
        ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(item.$1, color: journeyGreen),
            title: Text(item.$2),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => openJourney(context, item.$3)),
      const Divider(),
      JourneyButton(
          label: 'Se déconnecter',
          icon: Icons.logout,
          onPressed: () => logout(context)),
    ]);
  }
}
