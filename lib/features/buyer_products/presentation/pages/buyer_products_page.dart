import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/buyer_bottom_navigation.dart';
import '../../../buyer_purchases/presentation/pages/buyer_purchases_page.dart';
import '../../../buyer_needs/presentation/pages/publish_buyer_need_page.dart';
import '../../../buyer_profile/presentation/pages/buyer_profile_page.dart';
import 'buyer_product_detail_page.dart';
import 'buyer_empty_search_page.dart';

enum _ProductFilter { all, kaolack, available, price }

class BuyerProductsPage extends StatefulWidget {
  const BuyerProductsPage({super.key});

  static const String routeName = '/buyer-products';

  @override
  State<BuyerProductsPage> createState() => _BuyerProductsPageState();
}

class _BuyerProductsPageState extends State<BuyerProductsPage> {
  static const double _designWidth = 440;
  static const double _designHeight = 956;

  final TextEditingController _searchController = TextEditingController(
    text: 'Tomate',
  );
  _ProductFilter _selectedFilter = _ProductFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilters() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrer les produits',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.location_on_outlined),
                title: Text('Localisation'),
                subtitle: Text('Kaolack et environs'),
              ),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.payments_outlined),
                title: Text('Fourchette de prix'),
                subtitle: Text('200 à 500 FCFA / kg'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: const Color(0xFF087C3A),
                ),
                child: const Text('Afficher les résultats'),
              ),
            ],
          ),
        ),
      ),
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
        backgroundColor: AppColors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final scale = (constraints.maxWidth / _designWidth).clamp(0.1, 1.0);
            final scaledWidth = _designWidth * scale;
            final scaledHeight = _designHeight * scale;
            final navHeight = BuyerBottomNavigation.designHeight * scale;
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
                            child: _ProductsCanvas(
                              searchController: _searchController,
                              selectedFilter: _selectedFilter,
                              onFilterChanged: (filter) {
                                setState(() => _selectedFilter = filter);
                              },
                              onOpenFilters: _showFilters,
                              onSearchSubmitted: (query) {
                                final value = query.trim();
                                if (value.isEmpty) return;
                                Navigator.of(context).pushNamed(
                                  BuyerEmptySearchPage.routeName,
                                  arguments: BuyerEmptySearchArguments(
                                    query: value,
                                    location: 'Dakar',
                                  ),
                                );
                              },
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
                          height: BuyerBottomNavigation.designHeight,
                          child: BuyerBottomNavigation(
                            activeTab: BuyerNavigationTab.home,
                            onPrimaryAction: () => Navigator.of(
                              context,
                            ).pushNamed(PublishBuyerNeedPage.routeName),
                            onHome: () => Navigator.of(context).pop(),
                            onSearch: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            onReservations: () => Navigator.of(
                              context,
                            ).pushNamed(BuyerPurchasesPage.routeName),
                            onProfile: () => Navigator.of(
                              context,
                            ).pushNamed(BuyerProfilePage.routeName),
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

class _ProductsCanvas extends StatelessWidget {
  const _ProductsCanvas({
    required this.searchController,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onOpenFilters,
    required this.onSearchSubmitted,
  });

  final TextEditingController searchController;
  final _ProductFilter selectedFilter;
  final ValueChanged<_ProductFilter> onFilterChanged;
  final VoidCallback onOpenFilters;
  final ValueChanged<String> onSearchSubmitted;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 225,
            child: ColoredBox(color: Color(0xFF087C2E)),
          ),
          const Positioned(
            left: 27,
            right: 25,
            top: 69,
            child: _BuyerHeader(),
          ),
          Positioned(
            left: 25,
            right: 28,
            top: 153,
            child: _SearchField(
              controller: searchController,
              onOpenFilters: onOpenFilters,
              onSubmitted: onSearchSubmitted,
            ),
          ),
          Positioned(
            left: 32,
            right: 32,
            top: 238,
            child: _FilterRow(
              selectedFilter: selectedFilter,
              onChanged: onFilterChanged,
            ),
          ),
          const Positioned(
            left: 38,
            top: 294,
            child: Text(
              '24 résultats',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Positioned(
            left: 23,
            right: 23,
            top: 344,
            child: _ProductsGrid(),
          ),
        ],
      ),
    );
  }
}

class _BuyerHeader extends StatelessWidget {
  const _BuyerHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour, Amadou 👋',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Trouvez des produits disponibles',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
              child: ClipOval(
                child: Image.asset(
                  AppAssets.farmerProfile,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onOpenFilters,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final VoidCallback onOpenFilters;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 57,
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
          suffixIcon: IconButton(
            onPressed: onOpenFilters,
            icon: const Icon(
              Icons.tune_rounded,
              color: Color(0xFF087C3A),
            ),
          ),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.selectedFilter,
    required this.onChanged,
  });

  final _ProductFilter selectedFilter;
  final ValueChanged<_ProductFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterChip(
          label: 'Tous',
          selected: selectedFilter == _ProductFilter.all,
          onTap: () => onChanged(_ProductFilter.all),
        ),
        const SizedBox(width: 7),
        _FilterChip(
          label: 'Kaolack',
          selected: selectedFilter == _ProductFilter.kaolack,
          onTap: () => onChanged(_ProductFilter.kaolack),
        ),
        const SizedBox(width: 7),
        _FilterChip(
          label: 'Disponible',
          selected: selectedFilter == _ProductFilter.available,
          onTap: () => onChanged(_ProductFilter.available),
        ),
        const SizedBox(width: 7),
        _FilterChip(
          label: 'Prix',
          selected: selectedFilter == _ProductFilter.price,
          onTap: () => onChanged(_ProductFilter.price),
        ),
      ],
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
    return Expanded(
      child: SizedBox(
        height: 38,
        child: Material(
          color: selected ? const Color(0xFF00551F) : AppColors.white,
          shape: StadiumBorder(
            side: BorderSide(
              color:
                  selected ? const Color(0xFF00551F) : const Color(0xFFE0E4E9),
            ),
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? AppColors.white : const Color(0xFF374151),
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductsGrid extends StatelessWidget {
  const _ProductsGrid();

  @override
  Widget build(BuildContext context) {
    void openProduct(BuyerProductDetailData product) {
      Navigator.of(context).pushNamed(
        BuyerProductDetailPage.routeName,
        arguments: product,
      );
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ResultCard(
                imageAsset: AppAssets.buyerTomato,
                title: 'Tomate fraîche',
                price: '350 FCFA / kg',
                location: 'Thiès',
                onTap: () => openProduct(
                  const BuyerProductDetailData(
                    imageAsset: AppAssets.buyerTomato,
                    name: 'Tomate fraîche',
                    priceLabel: '400 FCFA / kg',
                    location: 'Nioro du Rip, Kaolack',
                    description:
                        'Tomate fraîche cultivée sans produits chimiques, idéale pour toutes préparations.',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: _ResultCard(
                imageAsset: AppAssets.buyerOnion,
                title: 'Oignon local',
                price: '250 FCFA / kg',
                location: 'Kaolack',
                onTap: () => openProduct(
                  const BuyerProductDetailData(
                    imageAsset: AppAssets.buyerOnion,
                    name: 'Oignon local',
                    priceLabel: '250 FCFA / kg',
                    location: 'Kaolack',
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ResultCard(
                imageAsset: AppAssets.buyerPotato,
                title: 'Pomme de terre',
                price: '300 FCFA / kg',
                location: 'Diourbel',
                onTap: () => openProduct(
                  const BuyerProductDetailData(
                    imageAsset: AppAssets.buyerPotato,
                    name: 'Pomme de terre',
                    priceLabel: '500 FCFA / kg',
                    location: 'Diourbel',
                    quantityLabel: 'Disponible prochainement',
                    availableSoon: true,
                    unitPrice: 500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: _ResultCard(
                imageAsset: AppAssets.buyerCorn,
                title: 'Maïs local',
                price: '200 FCFA / kg',
                location: 'Fatick',
                onTap: () => openProduct(
                  const BuyerProductDetailData(
                    imageAsset: AppAssets.buyerCorn,
                    name: 'Maïs local',
                    priceLabel: '200 FCFA / kg',
                    location: 'Fatick',
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.imageAsset,
    required this.title,
    required this.price,
    required this.location,
    required this.onTap,
  });

  final String imageAsset;
  final String title;
  final String price;
  final String location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                imageAsset,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            price,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF687284),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
              ),
              const Icon(Icons.star, color: Color(0xFFF7BD00), size: 16),
              const SizedBox(width: 4),
              const Text(
                '4.6',
                style: TextStyle(
                  color: Color(0xFFE9A900),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
