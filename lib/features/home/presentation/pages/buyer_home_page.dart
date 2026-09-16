import 'package:flutter/material.dart';
import '../../../../core/data/marketplace_models.dart';
import '../../../../core/data/marketplace_store.dart';
import '../../../../core/widgets/journey_scaffold.dart';
import '../../../buyer/presentation/buyer_journey_pages.dart';
import '../../../profile_selection/domain/entities/user_profile_type.dart';

class BuyerHomePage extends StatefulWidget {
  const BuyerHomePage({super.key});
  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> {
  String _category = 'Tous', _query = '';
  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.maybeOf(context);
    final activeOrders = store
            ?.records(RecordKind.order)
            .where((r) => [
                  RecordStatus.pending,
                  RecordStatus.accepted,
                  RecordStatus.active
                ].contains(r.status))
            .length ??
        0;
    final products = MarketplaceCatalog.products
        .where((p) =>
            (_category == 'Tous' || p.category == _category) &&
            p.name.toLowerCase().contains(_query.toLowerCase().trim()))
        .toList();
    return JourneyScaffold(
        title: 'Yokku Mbey',
        profileType: UserProfileType.buyer,
        root: true,
        homeHeader: true,
        children: [
          Row(children: [
            const Icon(Icons.location_on_outlined,
                size: 20, color: journeyMuted),
            const SizedBox(width: 6),
            Expanded(
                child: Text(store?.profile['region'] ?? 'Sénégal',
                    style: const TextStyle(fontWeight: FontWeight.w600))),
            IconButton(
                tooltip: 'Modifier ma région',
                onPressed: () => openJourney(context, '/account-personal'),
                icon: const Icon(Icons.chevron_right)),
          ]),
          Row(children: [
            Expanded(
                child: TextField(
                    decoration: const InputDecoration(
                        hintText: 'Rechercher un produit',
                        prefixIcon: Icon(Icons.search)),
                    onChanged: (v) => setState(() => _query = v))),
            const SizedBox(width: 10),
            IconButton.outlined(
                tooltip: 'Filtrer les produits',
                onPressed: () => openJourney(context, '/buyer-products'),
                icon: const Icon(Icons.tune)),
          ]),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: [
                'Tous',
                'Légumes',
                'Fruits',
                'Céréales',
                'Tubercules'
              ]
                      .map((c) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                              label: Text(c),
                              selected: c == _category,
                              onSelected: (_) =>
                                  setState(() => _category = c))))
                      .toList())),
          Material(
              color: const Color(0xFFEAF3FB),
              borderRadius: BorderRadius.circular(6),
              child: ListTile(
                  leading: const Icon(Icons.inventory_2_outlined,
                      color: Color(0xFF1E648D)),
                  title: Text(
                      activeOrders == 0
                          ? 'Mes réservations'
                          : '$activeOrders réservation${activeOrders > 1 ? 's' : ''} en cours',
                      style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1E648D),
                          fontWeight: FontWeight.w600)),
                  trailing:
                      const Icon(Icons.chevron_right, color: Color(0xFF1E648D)),
                  onTap: () => openJourneyTab(context, '/buyer-purchases'))),
          Row(children: [
            const Expanded(child: JourneyHeading('Produits disponibles')),
            TextButton(
                onPressed: () => openJourney(context, '/buyer-products'),
                child: const Text('Voir tout')),
          ]),
          if (products.isEmpty)
            const JourneyEmpty(
                title: 'Aucun produit trouvé',
                message: 'Essayez une autre recherche.'),
          ProductGrid(products: products),
          const JourneyHeading('Mon activité'),
          ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.assignment_outlined, color: journeyGreen),
              title: const Text('Mes demandes'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => openJourney(context, '/buyer-needs')),
          const Divider(),
          ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.favorite_border, color: journeyGreen),
              title: const Text('Favoris et alertes'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => openJourney(context, '/buyer-favorites')),
        ]);
  }
}
