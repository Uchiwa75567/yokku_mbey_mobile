import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../buyer_needs/presentation/pages/publish_buyer_need_page.dart';
import '../../../buyer_notifications/presentation/pages/buyer_notifications_page.dart';
import '../../../buyer_products/presentation/pages/buyer_product_detail_page.dart';
import '../../../buyer_products/presentation/pages/buyer_products_page.dart';
import '../../../buyer_profile/presentation/pages/buyer_profile_page.dart';
import '../../../buyer_purchases/presentation/pages/buyer_purchases_page.dart';
import '../widgets/buyer_bottom_navigation.dart';
import '../widgets/farmer_glass_surface.dart';

class BuyerHomePage extends StatelessWidget {
  const BuyerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.forestDeep,
        body: _BuyerHomeContent(),
      ),
    );
  }
}

class _BuyerHomeContent extends StatelessWidget {
  const _BuyerHomeContent();

  static const double _designWidth = 440;
  static const double _bottomNavigationHeight =
      BuyerBottomNavigation.designHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth > _designWidth
            ? _designWidth
            : constraints.maxWidth;
        final scale = (contentWidth / _designWidth).clamp(0.1, 1.0);
        final navigationHeight = _bottomNavigationHeight * scale;
        final bottomSafeInset = MediaQuery.viewPaddingOf(context).bottom;

        void openProducts() => Navigator.of(
              context,
            ).pushNamed(BuyerProductsPage.routeName);

        return Stack(
          fit: StackFit.expand,
          children: [
            const FarmerGlassBackground(
              assetPath: AppAssets.farmerHomeBackground,
              overlayOpacity: 0.38,
              blurSigma: 2,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66050B0D),
                    Color(0x33020A06),
                    Color(0xB304170C),
                  ],
                  stops: [0, 0.52, 1],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: contentWidth,
                height: constraints.maxHeight,
                child: SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: navigationHeight + bottomSafeInset + 24,
                    ),
                    child: _BuyerHomeBody(
                      onOpenProducts: openProducts,
                      onOpenNotifications: () => Navigator.of(
                        context,
                      ).pushNamed(BuyerNotificationsPage.routeName),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomSafeInset),
                child: SizedBox(
                  width: contentWidth,
                  height: navigationHeight,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: _designWidth,
                      height: _bottomNavigationHeight,
                      child: BuyerBottomNavigation(
                        activeTab: BuyerNavigationTab.home,
                        onSearch: openProducts,
                        onPrimaryAction: () => Navigator.of(
                          context,
                        ).pushNamed(PublishBuyerNeedPage.routeName),
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
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BuyerHomeBody extends StatelessWidget {
  const _BuyerHomeBody({
    required this.onOpenProducts,
    required this.onOpenNotifications,
  });

  final VoidCallback onOpenProducts;
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PremiumHeader(onOpenNotifications: onOpenNotifications),
          const SizedBox(height: 20),
          _SearchRow(onTap: onOpenProducts),
          const SizedBox(height: 24),
          _CategoriesSection(onCategoryTap: onOpenProducts),
          const SizedBox(height: 24),
          _ProductsSection(onViewAll: onOpenProducts),
        ],
      ),
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  const _PremiumHeader({required this.onOpenNotifications});

  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.55),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const ClipOval(
            child: Image(
              image: AssetImage(AppAssets.buyerHomeAvatar),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour,',
                style: TextStyle(
                  color: Color(0xE6FFFFFF),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.15,
                  shadows: [
                    Shadow(
                      color: Color(0x66000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Amadou',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  shadows: [
                    Shadow(
                      color: Color(0x66000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _NotificationButton(onTap: onOpenNotifications),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Notifications',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            FarmerGlassSurface(
              color: AppColors.white.withValues(alpha: 0.10),
              blurSigma: 14,
              borderRadius: BorderRadius.circular(22),
              borderColor: AppColors.white.withValues(alpha: 0.26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              child: const SizedBox.square(
                dimension: 42,
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.white,
                  size: 21,
                ),
              ),
            ),
            Positioned(
              right: 7,
              top: 7,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: 'Rechercher un produit',
            excludeSemantics: true,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.72),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: Color(0xFF6B7280),
                        size: 22,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Rechercher un produit...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Semantics(
          button: true,
          label: 'Filtrer les produits',
          excludeSemantics: true,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF07542B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.white,
                  size: 23,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection({required this.onCategoryTap});

  final VoidCallback onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle(title: 'Catégories'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _CategoryItem(
                label: 'Légumes',
                icon: Icons.eco_outlined,
                onTap: onCategoryTap,
              ),
            ),
            Expanded(
              child: _CategoryItem(
                label: 'Fruits',
                icon: Icons.local_florist_outlined,
                onTap: onCategoryTap,
              ),
            ),
            Expanded(
              child: _CategoryItem(
                label: 'Céréales',
                icon: Icons.grass_outlined,
                onTap: onCategoryTap,
              ),
            ),
            Expanded(
              child: _CategoryItem(
                label: 'Tubercules',
                icon: Icons.spa_outlined,
                onTap: onCategoryTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Catégorie $label',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            FarmerGlassSurface(
              color: AppColors.white.withValues(alpha: 0.10),
              blurSigma: 16,
              borderRadius: BorderRadius.circular(22),
              borderColor: AppColors.white.withValues(alpha: 0.24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              child: SizedBox.square(
                dimension: 64,
                child: Icon(icon, color: AppColors.white, size: 28),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.15,
                shadows: [
                  Shadow(color: Color(0x88000000), blurRadius: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductsSection extends StatelessWidget {
  const _ProductsSection({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          title: 'Produits disponibles',
          trailing: 'Voir tout',
          onTrailingTap: onViewAll,
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 238,
          child: PageView(
            padEnds: false,
            physics: const BouncingScrollPhysics(),
            children: const [
              _ProductPair(
                first: _ProductCard(
                  imageAsset: AppAssets.buyerHomeTomato,
                  detailImageAsset: AppAssets.buyerTomato,
                  title: 'Tomates Fraîches',
                  price: '450 FCFA/kg',
                  location: 'Niayes, Sénégal',
                  rating: '4.8',
                ),
                second: _ProductCard(
                  imageAsset: AppAssets.buyerHomeOnion,
                  detailImageAsset: AppAssets.buyerOnion,
                  title: 'Oignons Locaux',
                  price: '300 FCFA/kg',
                  location: 'Podor, Sénégal',
                  imageScale: 1.14,
                ),
              ),
              _ProductPair(
                first: _ProductCard(
                  imageAsset: AppAssets.buyerPotato,
                  title: 'Pomme de terre',
                  price: '300 FCFA / kg',
                  location: 'Diourbel',
                ),
                second: _ProductCard(
                  imageAsset: AppAssets.buyerCorn,
                  title: 'Maïs local',
                  price: '200 FCFA / kg',
                  location: 'Fatick',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductPair extends StatelessWidget {
  const _ProductPair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: first),
        const SizedBox(width: 12),
        Expanded(child: second),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.trailing,
    this.onTrailingTap,
  });

  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              height: 1.25,
              shadows: [
                Shadow(color: Color(0x88000000), blurRadius: 4),
              ],
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTrailingTap,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      trailing!,
                      style: const TextStyle(
                        color: Color(0xFFA2F5B6),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFFA2F5B6),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.imageAsset,
    required this.title,
    required this.price,
    required this.location,
    this.detailImageAsset,
    this.rating,
    this.imageScale = 1,
  });

  final String imageAsset;
  final String? detailImageAsset;
  final String title;
  final String price;
  final String location;
  final String? rating;
  final double imageScale;

  @override
  Widget build(BuildContext context) {
    final productImageAsset = detailImageAsset ?? imageAsset;

    return Semantics(
      button: true,
      label: '$title, $price, $location',
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(
          BuyerProductDetailPage.routeName,
          arguments: BuyerProductDetailData(
            imageAsset: productImageAsset,
            name: title,
            priceLabel: price,
            location: location,
            description: productImageAsset == AppAssets.buyerTomato
                ? 'Tomate fraîche cultivée sans produits chimiques, idéale pour toutes préparations.'
                : 'Produit frais sélectionné auprès d’un producteur vérifié YOKKU.',
            availableSoon: productImageAsset == AppAssets.buyerPotato,
            unitPrice: productImageAsset == AppAssets.buyerTomato
                ? 450
                : productImageAsset == AppAssets.buyerOnion
                    ? 300
                    : productImageAsset == AppAssets.buyerPotato
                        ? 500
                        : 200,
            quantityLabel: productImageAsset == AppAssets.buyerPotato
                ? 'Disponible prochainement'
                : '500 kg disponibles • minimum 50 kg',
          ),
        ),
        behavior: HitTestBehavior.opaque,
        child: FarmerGlassSurface(
          color: AppColors.white.withValues(alpha: 0.10),
          blurSigma: 16,
          borderRadius: BorderRadius.circular(22),
          borderColor: AppColors.white.withValues(alpha: 0.22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 128,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRect(
                      child: Transform.scale(
                        scale: imageScale,
                        alignment: Alignment.bottomCenter,
                        child: Image.asset(imageAsset, fit: BoxFit.cover),
                      ),
                    ),
                    if (rating != null)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.52),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.20),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppColors.orange,
                                size: 14,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                rating!,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xCCFFFFFF),
                            size: 14,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xCCFFFFFF),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        price,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFA2F5B6),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
