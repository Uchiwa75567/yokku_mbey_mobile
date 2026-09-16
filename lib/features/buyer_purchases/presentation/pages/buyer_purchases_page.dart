import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../buyer_needs/presentation/pages/publish_buyer_need_page.dart';
import '../../../buyer_profile/presentation/pages/buyer_profile_page.dart';
import '../../../buyer_products/presentation/pages/buyer_products_page.dart';
import '../../../home/presentation/widgets/buyer_bottom_navigation.dart';
import 'buyer_order_tracking_page.dart';

enum _PurchaseFilter { all, pending, inProgress, completed }

enum _PurchaseStatus { pending, inProgress, completed }

class BuyerPurchasesArguments {
  const BuyerPurchasesArguments({this.showEmptyState = false});

  final bool showEmptyState;
}

class BuyerPurchasesPage extends StatefulWidget {
  const BuyerPurchasesPage({
    super.key,
    this.arguments = const BuyerPurchasesArguments(),
  });

  static const String routeName = '/buyer-purchases';

  final BuyerPurchasesArguments arguments;

  static Widget fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return BuyerPurchasesPage(
      arguments: arguments is BuyerPurchasesArguments
          ? arguments
          : const BuyerPurchasesArguments(),
    );
  }

  @override
  State<BuyerPurchasesPage> createState() => _BuyerPurchasesPageState();
}

class _BuyerPurchasesPageState extends State<BuyerPurchasesPage> {
  _PurchaseFilter _selectedFilter = _PurchaseFilter.all;

  List<_Purchase> get _visiblePurchases {
    if (widget.arguments.showEmptyState) return const [];
    return switch (_selectedFilter) {
      _PurchaseFilter.all => _purchases,
      _PurchaseFilter.pending => _purchases
          .where((purchase) => purchase.status == _PurchaseStatus.pending)
          .toList(),
      _PurchaseFilter.inProgress => _purchases
          .where((purchase) => purchase.status == _PurchaseStatus.inProgress)
          .toList(),
      _PurchaseFilter.completed => _purchases
          .where((purchase) => purchase.status == _PurchaseStatus.completed)
          .toList(),
    };
  }

  void _showPurchase(_Purchase purchase) {
    Navigator.of(context).pushNamed(
      BuyerOrderTrackingPage.routeName,
      arguments: BuyerOrderTrackingArguments(
        productName: purchase.name,
        quantityKg: purchase.quantityKg,
        amount: purchase.amount,
        orderNumber: purchase.reference,
        completedSteps: switch (purchase.status) {
          _PurchaseStatus.pending => 1,
          _PurchaseStatus.inProgress => 3,
          _PurchaseStatus.completed => 5,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: _PurchasePalette.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _PurchasePalette.background,
        body: Stack(
          children: [
            const Positioned.fill(child: _AgriculturalBackground()),
            Positioned.fill(
              top: _PurchasesHeader.height,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  if (!widget.arguments.showEmptyState)
                    SliverToBoxAdapter(
                      child: _FiltersBar(
                        selectedFilter: _selectedFilter,
                        onChanged: (filter) {
                          setState(() => _selectedFilter = filter);
                        },
                      ),
                    ),
                  if (_visiblePurchases.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyPurchases(
                        firstPurchase: widget.arguments.showEmptyState,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        28 + bottomInset,
                      ),
                      sliver: SliverList.separated(
                        itemCount: _visiblePurchases.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final purchase = _visiblePurchases[index];
                          return _PurchaseCard(
                            purchase: purchase,
                            onView: () => _showPurchase(purchase),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: _PurchasesHeader(
                showBackButton: !widget.arguments.showEmptyState,
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: SizedBox(
            height: BuyerBottomNavigation.designHeight,
            child: FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: 440,
                height: BuyerBottomNavigation.designHeight,
                child: BuyerBottomNavigation(
                  activeTab: BuyerNavigationTab.reservations,
                  onHome: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  onSearch: () => Navigator.of(
                    context,
                  ).pushNamed(BuyerProductsPage.routeName),
                  onPrimaryAction: () => Navigator.of(
                    context,
                  ).pushNamed(PublishBuyerNeedPage.routeName),
                  onProfile: () => Navigator.of(
                    context,
                  ).pushNamed(BuyerProfilePage.routeName),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

abstract final class _PurchasePalette {
  static const background = Color(0xFFF8F9FA);
  static const primary = Color(0xFF004722);
  static const ink = Color(0xFF191C1D);
  static const mutedInk = Color(0xFF3F4940);
  static const outline = Color(0xFFBFC9BD);
}

class _AgriculturalBackground extends StatelessWidget {
  const _AgriculturalBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          AppAssets.farmerHomeBackground,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
        ColoredBox(color: Colors.black.withValues(alpha: 0.24)),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, 0.36, 0.72, 1],
              colors: [
                Color(0x18000000),
                Color(0x9AF8F9FA),
                Color(0xF2F8F9FA),
                _PurchasePalette.background,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PurchasesHeader extends StatelessWidget {
  const _PurchasesHeader({required this.showBackButton});

  static const double height = 64;

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _PurchasePalette.background.withValues(alpha: 0.82),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (showBackButton)
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: 'Retour',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: _PurchasePalette.primary,
                )
              else
                const SizedBox(width: 8),
              const SizedBox(width: 4),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mes achats',
                      style: TextStyle(
                        color: _PurchasePalette.primary,
                        fontSize: 19,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.25,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Suivez vos commandes',
                      style: TextStyle(
                        color: _PurchasePalette.mutedInk,
                        fontSize: 11,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.more_vert_rounded,
                  color: _PurchasePalette.primary,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.selectedFilter,
    required this.onChanged,
  });

  final _PurchaseFilter selectedFilter;
  final ValueChanged<_PurchaseFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          _FilterChip(
            label: 'Tous',
            selected: selectedFilter == _PurchaseFilter.all,
            onTap: () => onChanged(_PurchaseFilter.all),
          ),
          const SizedBox(width: 10),
          _FilterChip(
            label: 'En attente',
            selected: selectedFilter == _PurchaseFilter.pending,
            onTap: () => onChanged(_PurchaseFilter.pending),
          ),
          const SizedBox(width: 10),
          _FilterChip(
            label: 'En cours',
            selected: selectedFilter == _PurchaseFilter.inProgress,
            onTap: () => onChanged(_PurchaseFilter.inProgress),
          ),
          const SizedBox(width: 10),
          _FilterChip(
            label: 'Terminés',
            selected: selectedFilter == _PurchaseFilter.completed,
            onTap: () => onChanged(_PurchaseFilter.completed),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: selected
              ? _PurchasePalette.primary.withValues(alpha: 0.94)
              : Colors.white.withValues(alpha: 0.68),
          shape: StadiumBorder(
            side: BorderSide(
              color: selected
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.55),
            ),
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.white : _PurchasePalette.mutedInk,
                  fontSize: 12,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard({required this.purchase, required this.onView});

  final _Purchase purchase;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final status = _statusVisual(purchase.status);
    final card = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.62),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 96,
                    child: Image.asset(
                      purchase.imageAsset,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        purchase.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _PurchasePalette.ink,
                          fontSize: 15,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: status.backgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.label,
                        maxLines: 1,
                        style: TextStyle(
                          color: status.color,
                          fontSize: 10,
                          height: 1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '${purchase.quantityKg} kg • ${_formatAmount(purchase.amount)} FCFA',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _PurchasePalette.mutedInk,
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: _PurchasePalette.outline.withValues(alpha: 0.30),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Commande #${purchase.reference}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _PurchasePalette.mutedInk,
                          fontSize: 10,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onView,
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 3,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Voir',
                              style: TextStyle(
                                color: _PurchasePalette.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: _PurchasePalette.primary,
                              size: 13,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (purchase.status == _PurchaseStatus.completed) {
      return Opacity(opacity: 0.82, child: card);
    }
    return card;
  }
}

class _EmptyPurchases extends StatelessWidget {
  const _EmptyPurchases({required this.firstPurchase});

  final bool firstPurchase;

  @override
  Widget build(BuildContext context) {
    if (!firstPurchase) {
      return const Center(
        child: _GlassEmptyMessage(
          child: Text(
            'Aucun achat dans cette catégorie',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _PurchasePalette.mutedInk,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 44),
      child: Center(
        child: _GlassEmptyMessage(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.64),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: _PurchasePalette.primary,
                  size: 46,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Aucun achat pour le moment',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _PurchasePalette.primary,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Explorez les produits disponibles et effectuez votre\n'
                'première réservation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _PurchasePalette.mutedInk,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 30),
              FilledButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  BuyerProductsPage.routeName,
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: _PurchasePalette.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Explorer le marché',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassEmptyMessage extends StatelessWidget {
  const _GlassEmptyMessage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.60)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Purchase {
  const _Purchase({
    required this.imageAsset,
    required this.name,
    required this.quantityKg,
    required this.amount,
    required this.reference,
    required this.status,
  });

  final String imageAsset;
  final String name;
  final int quantityKg;
  final int amount;
  final String reference;
  final _PurchaseStatus status;
}

typedef _StatusVisual = ({
  String label,
  Color color,
  Color backgroundColor,
});

_StatusVisual _statusVisual(_PurchaseStatus status) {
  return switch (status) {
    _PurchaseStatus.pending => (
        label: 'En attente',
        color: const Color(0xFFEA580C),
        backgroundColor: const Color(0xFFFFE8DC),
      ),
    _PurchaseStatus.inProgress => (
        label: 'En préparation',
        color: const Color(0xFF1D4ED8),
        backgroundColor: const Color(0xFFDBEAFE),
      ),
    _PurchaseStatus.completed => (
        label: 'Terminée',
        color: const Color(0xFF16A34A),
        backgroundColor: const Color(0xFFDCFCE7),
      ),
  };
}

const List<_Purchase> _purchases = [
  _Purchase(
    imageAsset: AppAssets.buyerPurchaseTomato,
    name: 'Tomate fraîche',
    quantityKg: 200,
    amount: 80000,
    reference: 'YM-8492',
    status: _PurchaseStatus.pending,
  ),
  _Purchase(
    imageAsset: AppAssets.buyerPurchaseOnion,
    name: 'Oignon local',
    quantityKg: 500,
    amount: 175000,
    reference: 'YM-8490',
    status: _PurchaseStatus.inProgress,
  ),
  _Purchase(
    imageAsset: AppAssets.buyerPurchasePotato,
    name: 'Pomme de terre',
    quantityKg: 150,
    amount: 75000,
    reference: 'YM-8485',
    status: _PurchaseStatus.completed,
  ),
];

String _formatAmount(int value) {
  return value.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ' ',
      );
}
