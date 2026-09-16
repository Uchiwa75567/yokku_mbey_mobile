import 'package:flutter/material.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/widgets/journey_scaffold.dart';

class FarmerHomePage extends StatelessWidget {
  const FarmerHomePage({super.key});
  @override
  Widget build(BuildContext context) => JourneyScaffold(
          title: 'Yokku Mbey',
          homeHeader: true,
          root: true,
          children: [
            const JourneyHeading('Mon activité agricole'),
            const JourneyNotice(
                'Les chiffres et les annonces agriculteur ci-dessous sont des exemples de démonstration.'),
            ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    const Icon(Icons.agriculture_outlined, color: journeyGreen),
                title: const Text('Travail et matériel',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Ouvriers, tracteurs et prestations'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openJourney(context, '/farmer-services')),
            Material(
                color: const Color(0xFFEAF3FB),
                borderRadius: BorderRadius.circular(6),
                child: ListTile(
                    leading: const Icon(Icons.inventory_2_outlined,
                        color: Color(0xFF226A91)),
                    title: const Text('Réservations reçues',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        openJourney(context, '/reservations-received'))),
            LayoutBuilder(
                builder: (context, constraints) =>
                    Wrap(spacing: 12, runSpacing: 12, children: [
                      for (final item in <(IconData, String, String)>[
                        (
                          Icons.grass_outlined,
                          'Mes récoltes',
                          '/farmer-harvests'
                        ),
                        (
                          Icons.storefront_outlined,
                          'Produits recherchés',
                          '/wanted-products'
                        ),
                        (
                          Icons.agriculture_outlined,
                          'Mes besoins',
                          '/my-needs'
                        ),
                        (
                          Icons.handshake_outlined,
                          'Opportunités',
                          '/opportunities'
                        ),
                      ])
                        SizedBox(
                            width: (constraints.maxWidth - 12) / 2,
                            child: JourneyCard(
                                onTap: () => openJourney(context, item.$3),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(item.$1,
                                          color: journeyGreen, size: 26),
                                      const SizedBox(height: 14),
                                      Text(item.$2,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: journeyInk)),
                                    ]))),
                    ])),
            Row(children: [
              const Expanded(child: JourneyHeading('Mes récoltes')),
              TextButton(
                  onPressed: () => openJourney(context, '/farmer-harvests'),
                  child: const Text('Voir tout'))
            ]),
            JourneyCard(
                padding: EdgeInsets.zero,
                onTap: () => openJourney(context, '/harvest-detail'),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AspectRatio(
                          aspectRatio: 2.2,
                          child: Image.asset(AppAssets.farmerTomatoHarvest,
                              fit: BoxFit.cover)),
                      const Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tomates fraîches',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: journeyInk)),
                                SizedBox(height: 6),
                                Text('Récolte disponible · Kaolack',
                                    style: TextStyle(color: journeyMuted)),
                              ])),
                    ])),
            JourneyButton(
                label: 'Ajouter une récolte',
                icon: Icons.add,
                onPressed: () async =>
                    openJourney(context, '/publish-harvest')),
            const Divider(),
            ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.account_balance_wallet_outlined,
                    color: journeyGreen),
                title: const Text('Paiements et retraits'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openJourney(context, '/payments-withdrawals')),
          ]);
}
