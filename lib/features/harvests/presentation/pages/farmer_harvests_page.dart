import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../harvest_boost/presentation/pages/harvest_boost_page.dart';
import '../../../harvest_detail/presentation/pages/harvest_detail_page.dart';
import '../../../harvest_edit/presentation/pages/harvest_edit_page.dart';
import '../../../harvest_publication/presentation/pages/harvest_publication_page.dart';
import '../../../home/presentation/widgets/farmer_bottom_navigation.dart';
import '../../../home/presentation/widgets/farmer_glass_surface.dart';
import '../../../reservations/presentation/pages/reservations_received_page.dart';
import '../../../profile/presentation/pages/farmer_profile_page.dart';
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
  static const double _designWidth = 440;
  static const double _designHeight = 1190;
  static const double _bottomNavigationHeight =
      FarmerBottomNavigation.designHeight;

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
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF18241D),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final scale = (constraints.maxWidth / _designWidth).clamp(0.1, 1.0);
            final scaledWidth = _designWidth * scale;
            final scaledHeight = _designHeight * scale;
            final navHeight = _bottomNavigationHeight * scale;
            final bottomSafeInset = MediaQuery.viewPaddingOf(context).bottom;

            return Center(
              child: SizedBox(
                width: scaledWidth,
                height: constraints.maxHeight,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: navHeight + bottomSafeInset + 18,
                      ),
                      child: SizedBox(
                        width: scaledWidth,
                        height: scaledHeight,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            width: _designWidth,
                            height: _designHeight,
                            child: _HarvestsCanvas(
                              selectedFilter: _selectedFilter,
                              harvests: _visibleHarvests,
                              onFilterChanged: (filter) {
                                setState(() => _selectedFilter = filter);
                              },
                              onView: _viewHarvest,
                              onEdit: (harvest) {
                                Navigator.of(context).pushNamed(
                                  HarvestEditPage.routeName,
                                  arguments: harvest.editData,
                                );
                              },
                              onBoost: (harvest) {
                                Navigator.of(context).pushNamed(
                                  HarvestBoostPage.routeName,
                                  arguments: HarvestBoostData(
                                    name: harvest.name,
                                    quantityLabel: harvest.quantityLabel
                                        .replaceAll(' disponibles', '')
                                        .replaceAll(' estimées', ''),
                                    priceLabel: harvest.priceLabel,
                                  ),
                                );
                              },
                              onMenu: _showHarvestMenu,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: bottomSafeInset,
                      height: navHeight,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        alignment: Alignment.bottomLeft,
                        child: SizedBox(
                          width: _designWidth,
                          height: _bottomNavigationHeight,
                          child: FarmerBottomNavigation(
                            activeTab: FarmerNavigationTab.harvests,
                            onHome: () => Navigator.of(context).maybePop(),
                            onPublishHarvest: () {
                              Navigator.of(context).pushNamed(
                                HarvestPublicationPage.routeName,
                              );
                            },
                            onReservations: () {
                              Navigator.of(context).pushReplacementNamed(
                                ReservationsReceivedPage.routeName,
                              );
                            },
                            onProfile: () {
                              Navigator.of(context).pushNamed(
                                FarmerProfilePage.routeName,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HarvestsCanvas extends StatelessWidget {
  const _HarvestsCanvas({
    required this.selectedFilter,
    required this.harvests,
    required this.onFilterChanged,
    required this.onView,
    required this.onEdit,
    required this.onBoost,
    required this.onMenu,
  });

  final _HarvestFilter selectedFilter;
  final List<_HarvestListing> harvests;
  final ValueChanged<_HarvestFilter> onFilterChanged;
  final ValueChanged<_HarvestListing> onView;
  final ValueChanged<_HarvestListing> onEdit;
  final ValueChanged<_HarvestListing> onBoost;
  final ValueChanged<_HarvestListing> onMenu;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: FarmerGlassBackground(overlayOpacity: 0.42),
        ),
        const Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 66,
          child: FarmerGlassSurface(
            color: Color(0x1AFFFFFF),
            blurSigma: 16,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(26),
            ),
            borderColor: Color(0x33FFFFFF),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 32,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0x33FFFFFF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.eco_rounded,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Yokku Mbey',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.white,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
        const Positioned(
          left: 20,
          top: 82,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mes récoltes',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Gérez toutes vos annonces',
                style: TextStyle(
                  color: Color(0xB3FFFFFF),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          top: 133,
          child: _HarvestFilters(
            selectedFilter: selectedFilter,
            onChanged: onFilterChanged,
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          top: 199,
          child: harvests.isEmpty
              ? const _EmptyHarvests()
              : Column(
                  children: harvests.indexed.map((entry) {
                    final index = entry.$1;
                    final harvest = entry.$2;
                    return Padding(
                      padding: EdgeInsets.only(top: index == 0 ? 0 : 16),
                      child: _HarvestCard(
                        harvest: harvest,
                        onView: () => onView(harvest),
                        onEdit: () => onEdit(harvest),
                        onBoost: () => onBoost(harvest),
                        onMenu: () => onMenu(harvest),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

class _HarvestFilters extends StatelessWidget {
  const _HarvestFilters({
    required this.selectedFilter,
    required this.onChanged,
  });

  final _HarvestFilter selectedFilter;
  final ValueChanged<_HarvestFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterButton(
          label: 'Toutes',
          selected: selectedFilter == _HarvestFilter.all,
          onTap: () => onChanged(_HarvestFilter.all),
        ),
        const SizedBox(width: 7),
        _FilterButton(
          label: 'Actives',
          selected: selectedFilter == _HarvestFilter.active,
          onTap: () => onChanged(_HarvestFilter.active),
        ),
        const SizedBox(width: 7),
        _FilterButton(
          label: 'À venir',
          selected: selectedFilter == _HarvestFilter.upcoming,
          onTap: () => onChanged(_HarvestFilter.upcoming),
        ),
        const SizedBox(width: 7),
        _FilterButton(
          label: 'Épuisées',
          selected: selectedFilter == _HarvestFilter.exhausted,
          onTap: () => onChanged(_HarvestFilter.exhausted),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 31,
        child: Material(
          color: selected ? const Color(0xFF176B36) : const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(99),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(99),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF176B36)
                      : const Color(0x4DFFFFFF),
                ),
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HarvestCard extends StatelessWidget {
  const _HarvestCard({
    required this.harvest,
    required this.onView,
    required this.onEdit,
    required this.onBoost,
    required this.onMenu,
  });

  final _HarvestListing harvest;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onBoost;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 298,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE4EAE5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF173C28).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 143,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(harvest.imagePath, fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xB3000000)],
                      stops: [0.48, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 12,
                  child: Text(
                    harvest.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      shadows: [
                        Shadow(color: Color(0x66000000), blurRadius: 5),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 11,
                  child: _HarvestStatusBadge(status: harvest.status),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 13, 15, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _HarvestMetric(
                        label: harvest.status == _HarvestStatus.upcoming
                            ? 'Estimation'
                            : 'Quantité',
                        value: harvest.quantityLabel
                            .replaceAll(' disponibles', '')
                            .replaceAll(' estimées', ''),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 34,
                      color: const Color(0xFFE7ECE8),
                    ),
                    Expanded(
                      child: _HarvestMetric(
                        label: harvest.status == _HarvestStatus.upcoming
                            ? 'Prix ind.'
                            : 'Prix',
                        value: harvest.priceLabel,
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      harvest.status == _HarvestStatus.exhausted
                          ? Icons.check_circle_outline
                          : Icons.event_note_outlined,
                      color: const Color(0xFF67756C),
                      size: 14,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      harvest.status == _HarvestStatus.exhausted
                          ? '${harvest.activityLabel} terminées'
                          : harvest.activityLabel,
                      style: const TextStyle(
                        color: Color(0xFF657169),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFECEFED)),
          SizedBox(
            height: 48,
            child: Row(
              children: [
                _HarvestAction(
                  label: 'Voir',
                  color: const Color(0xFF516058),
                  onTap: onView,
                ),
                _HarvestAction(
                  label: 'Modifier',
                  color: const Color(0xFF516058),
                  onTap: onEdit,
                ),
                _HarvestAction(
                  label: 'Booster',
                  color: const Color(0xFF176B36),
                  filled: harvest.status != _HarvestStatus.exhausted,
                  enabled: harvest.status != _HarvestStatus.exhausted,
                  onTap: onBoost,
                ),
                SizedBox(
                  width: 48,
                  child: IconButton(
                    tooltip: 'Plus d’actions',
                    onPressed: onMenu,
                    icon: const Icon(
                      Icons.more_horiz,
                      color: Color(0xFF77827B),
                      size: 21,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HarvestMetric extends StatelessWidget {
  const _HarvestMetric({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7B867F),
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF1D2A22),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HarvestAction extends StatelessWidget {
  const _HarvestAction({
    required this.label,
    required this.color,
    required this.onTap,
    this.filled = false,
    this.enabled = true,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool filled;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
        child: TextButton(
          onPressed: enabled ? onTap : null,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            backgroundColor: filled ? color : Colors.transparent,
            disabledForegroundColor: const Color(0xFFB4BBB6),
            foregroundColor: filled ? AppColors.white : color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _HarvestStatusBadge extends StatelessWidget {
  const _HarvestStatusBadge({required this.status});

  final _HarvestStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, backgroundColor) = switch (status) {
      _HarvestStatus.available => (
          'ACTIVE',
          const Color(0xFF187C3A),
          const Color(0xFFDDF5E3),
        ),
      _HarvestStatus.upcoming => (
          'À VENIR',
          const Color(0xFFD56D00),
          const Color(0xFFFFF3E5),
        ),
      _HarvestStatus.exhausted => (
          'ÉPUISÉE',
          const Color(0xFFD9363E),
          const Color(0xFFFFE9EC),
        ),
    };

    return Container(
      height: 23,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _EmptyHarvests extends StatelessWidget {
  const _EmptyHarvests();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF3)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: Color(0xFF95A2B5),
            size: 38,
          ),
          SizedBox(height: 13),
          Text(
            'Aucune récolte dans cette catégorie',
            style: TextStyle(
              color: Color(0xFF68758A),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
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
