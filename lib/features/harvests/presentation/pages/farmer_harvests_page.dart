import '../../../../core/widgets/journey_scaffold.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../harvest_boost/presentation/pages/harvest_boost_page.dart';
import '../../../harvest_detail/presentation/pages/harvest_detail_page.dart';
import '../../../harvest_edit/presentation/pages/harvest_edit_page.dart';
import '../../../stock_management/presentation/pages/stock_management_page.dart';

enum _HarvestFilter { all, active, upcoming, exhausted }

enum _HarvestStatus { available, upcoming, exhausted }

class FarmerHarvestsPage extends StatefulWidget {
  const FarmerHarvestsPage({super.key});

  static const String routeName = '/farmer-harvests';

  @override
  State<FarmerHarvestsPage> createState() => _FarmerHarvestsPageState();
}

class _FarmerHarvestsPageState extends State<FarmerHarvestsPage> {
  _HarvestFilter _selectedFilter = _HarvestFilter.all;

  List<_HarvestListing> get _visibleHarvests {
    return switch (_selectedFilter) {
      _HarvestFilter.all => _harvests,
      _HarvestFilter.active => _harvests
          .where((harvest) => harvest.status == _HarvestStatus.available)
          .toList(),
      _HarvestFilter.upcoming => _harvests
          .where((harvest) => harvest.status == _HarvestStatus.upcoming)
          .toList(),
      _HarvestFilter.exhausted => _harvests
          .where((harvest) => harvest.status == _HarvestStatus.exhausted)
          .toList(),
    };
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _viewHarvest(_HarvestListing harvest) {
    if (harvest.id == 'tomato') {
      Navigator.of(context).pushNamed(HarvestDetailPage.routeName);
      return;
    }

    _showMessage('Détail de ${harvest.name} bientôt disponible');
  }

  Future<void> _showHarvestMenu(_HarvestListing harvest) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: const Text('Gérer le stock'),
                onTap: () => Navigator.of(context).pop('stock'),
              ),
              ListTile(
                leading: const Icon(Icons.pause_circle_outline),
                title: const Text('Mettre l’annonce en pause'),
                onTap: () => Navigator.of(context).pop('pause'),
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFE43E45),
                ),
                title: const Text(
                  'Supprimer l’annonce',
                  style: TextStyle(color: Color(0xFFE43E45)),
                ),
                onTap: () => Navigator.of(context).pop('delete'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }

    if (action == 'stock') {
      await Navigator.of(context).pushNamed(
        StockManagementPage.routeName,
        arguments: harvest.stockData,
      );
      return;
    }

    _showMessage(
      action == 'pause'
          ? '${harvest.name} a été mise en pause'
          : 'Suppression de ${harvest.name} à confirmer',
    );
  }

  @override
  Widget build(BuildContext context) =>
      JourneyScaffold(title: 'Mes récoltes', root: true, tab: 1, children: [
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _HarvestFilter.values
                .map((filter) => ChoiceChip(
                    label: Text([
                      'Toutes',
                      'Actives',
                      'À venir',
                      'Épuisées'
                    ][filter.index]),
                    selected: filter == _selectedFilter,
                    onSelected: (_) =>
                        setState(() => _selectedFilter = filter)))
                .toList()),
        if (_visibleHarvests.isEmpty)
          const JourneyEmpty(
              title: 'Aucune récolte dans cette catégorie',
              message: 'Retrouvez vos autres annonces dans Toutes.'),
        for (final harvest in _visibleHarvests)
          JourneyCard(
              padding: EdgeInsets.zero,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                        aspectRatio: 2.2,
                        child:
                            Image.asset(harvest.imagePath, fit: BoxFit.cover)),
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                    child: Text(harvest.name,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: journeyInk))),
                                IconButton(
                                    tooltip: 'Plus d’actions',
                                    onPressed: () => _showHarvestMenu(harvest),
                                    icon: const Icon(Icons.more_horiz)),
                              ]),
                              Text(harvest.quantityLabel,
                                  style: const TextStyle(color: journeyMuted)),
                              const SizedBox(height: 8),
                              Text(harvest.priceLabel,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: journeyGreen)),
                              const SizedBox(height: 14),
                              Wrap(spacing: 8, runSpacing: 8, children: [
                                OutlinedButton.icon(
                                    onPressed: () => _viewHarvest(harvest),
                                    icon: const Icon(Icons.visibility_outlined,
                                        size: 18),
                                    label: const Text('Voir')),
                                OutlinedButton.icon(
                                    onPressed: () => openJourney(
                                        context, HarvestEditPage.routeName,
                                        arguments: harvest.editData),
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 18),
                                    label: const Text('Modifier')),
                                OutlinedButton.icon(
                                    onPressed: harvest.status ==
                                            _HarvestStatus.exhausted
                                        ? null
                                        : () => openJourney(
                                            context, HarvestBoostPage.routeName,
                                            arguments: HarvestBoostData(
                                                name: harvest.name,
                                                quantityLabel:
                                                    harvest.quantityLabel,
                                                priceLabel:
                                                    harvest.priceLabel)),
                                    icon:
                                        const Icon(Icons.trending_up, size: 18),
                                    label: const Text('Booster')),
                              ]),
                            ])),
                  ])),
        const JourneyNotice('Annonces de démonstration.'),
      ]);
}

class _HarvestListing {
  const _HarvestListing({
    required this.id,
    required this.name,
    required this.quantityLabel,
    required this.priceLabel,
    required this.activityLabel,
    required this.imagePath,
    required this.status,
  });

  final String id;
  final String name;
  final String quantityLabel;
  final String priceLabel;
  final String activityLabel;
  final String imagePath;
  final _HarvestStatus status;

  HarvestEditData get editData {
    return switch (id) {
      'onion' => const HarvestEditData(
          name: 'Oignon local',
          unitPrice: 350,
          remainingQuantity: 2000,
          minimumOrder: 100,
          availability: 'Disponible prochainement',
          reservationCount: 7,
        ),
      'potato' => const HarvestEditData(
          name: 'Pomme de terre',
          unitPrice: 500,
          remainingQuantity: 0,
          minimumOrder: 50,
          availability: 'Épuisée',
          reservationCount: 0,
        ),
      _ => HarvestEditPage.defaultHarvest,
    };
  }

  StockManagementData get stockData {
    return switch (id) {
      'onion' => const StockManagementData(
          productName: 'Oignon local',
          initialQuantity: 2000,
          reservedQuantity: 700,
          soldQuantity: 0,
          remainingQuantity: 1300,
        ),
      'potato' => const StockManagementData(
          productName: 'Pomme de terre',
          initialQuantity: 1200,
          reservedQuantity: 0,
          soldQuantity: 1200,
          remainingQuantity: 0,
        ),
      _ => StockManagementPage.defaultStock,
    };
  }
}

const List<_HarvestListing> _harvests = [
  _HarvestListing(
    id: 'tomato',
    name: 'Tomate fraîche',
    quantityLabel: '500 kg disponibles',
    priceLabel: '400 FCFA/kg',
    activityLabel: '18 réservations',
    imagePath: AppAssets.farmerTomatoHarvest,
    status: _HarvestStatus.available,
  ),
  _HarvestListing(
    id: 'onion',
    name: 'Oignon local',
    quantityLabel: '2 tonnes estimées',
    priceLabel: '350 FCFA/kg',
    activityLabel: '7 réservations',
    imagePath: AppAssets.buyerOnion,
    status: _HarvestStatus.upcoming,
  ),
  _HarvestListing(
    id: 'potato',
    name: 'Pomme de terre',
    quantityLabel: '0 kg disponibles',
    priceLabel: '500 FCFA/kg',
    activityLabel: '24 ventes',
    imagePath: AppAssets.buyerPotato,
    status: _HarvestStatus.exhausted,
  ),
];
