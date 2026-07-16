import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class BuyerHomePage extends StatelessWidget {
  const BuyerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: _BuyerHomeContent(),
      ),
    );
  }
}

class _BuyerHomeContent extends StatelessWidget {
  const _BuyerHomeContent();

  static const double _designWidth = 440;
  static const double _designHeight = 956;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return const SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: SizedBox(
              width: _designWidth,
              height: _designHeight,
              child: _BuyerHomeCanvas(),
            ),
          ),
        );
      },
    );
  }
}

class _BuyerHomeCanvas extends StatelessWidget {
  const _BuyerHomeCanvas();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.white,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _HeaderBand(),
          _SearchBox(),
          _ProductsSection(),
          _CategoriesSection(),
          _BottomNavigation(),
        ],
      ),
    );
  }
}

class _HeaderBand extends StatelessWidget {
  const _HeaderBand();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      width: 440,
      height: 225,
      child: ColoredBox(
        color: const Color(0xFF0B731B),
        child: Stack(
          children: [
            const Positioned(
              left: 27,
              top: 72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour, Amadou 👋',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.32,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Voici votre activité du jour',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.42,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 29,
              top: 72,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(AppAssets.yokkuMbeyLogo),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1E5631),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      right: 28,
      top: 153,
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'Rechercher un produit...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.softInk,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductsSection extends StatelessWidget {
  const _ProductsSection();

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      left: 19,
      right: 19,
      top: 247,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            title: 'Produits disponibles maintenant',
            trailing: 'Voir tout',
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ProductCard(
                  imageAsset: AppAssets.buyerTomato,
                  title: 'Tomate fraiche',
                  price: '350 FCFA / kg',
                  location: 'Thiés',
                ),
              ),
              SizedBox(width: 30),
              Expanded(
                child: _ProductCard(
                  imageAsset: AppAssets.buyerOnion,
                  title: 'Oignon local',
                  price: '250 FCFA / kg',
                  location: 'Kaolack',
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ProductCard(
                  imageAsset: AppAssets.buyerPotato,
                  title: 'Pomme de terre',
                  price: '300 FCFA / kg',
                  location: 'Diourbel',
                ),
              ),
              SizedBox(width: 30),
              Expanded(
                child: _ProductCard(
                  imageAsset: AppAssets.buyerCorn,
                  title: 'Mais local',
                  price: '200 FCFA / kg',
                  location: 'Fatick',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.trailing,
  });

  final String title;
  final String trailing;

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
              color: Color(0xFF1F2937),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.55,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          trailing,
          style: const TextStyle(
            color: Color(0xFF4CAF50),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.42,
            letterSpacing: 0,
          ),
        ),
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
  });

  final String imageAsset;
  final String title;
  final String price;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(
            imageAsset,
            width: double.infinity,
            height: 166,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          price,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.softInk,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            height: 1.18,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          location,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.2,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection();

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      left: 24,
      right: 24,
      top: 808,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            title: 'Catégories populaires',
            trailing: 'Voir tout',
          ),
          SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CategoryItem(
                label: 'Céréales',
                icon: Icons.grass_outlined,
                color: AppColors.leaf,
                backgroundColor: AppColors.greenSoft,
              ),
              _CategoryItem(
                label: 'Légumes',
                icon: Icons.eco_outlined,
                color: AppColors.leaf,
                backgroundColor: AppColors.greenSoft,
              ),
              _CategoryItem(
                label: 'Fruits',
                icon: Icons.local_florist_outlined,
                color: AppColors.orange,
                backgroundColor: AppColors.orangeSoft,
              ),
              _CategoryItem(
                label: 'Tubercules',
                icon: Icons.spa_outlined,
                color: AppColors.orange,
                backgroundColor: AppColors.orangeSoft,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          SizedBox.square(
            dimension: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.mutedInk,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.1,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 25,
      right: 25,
      bottom: 0,
      child: SizedBox(
        height: 74,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFF3F4F6)),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BottomNavItem(
                    icon: Icons.home,
                    label: 'Accueil',
                    isActive: true,
                  ),
                  _BottomNavItem(
                    icon: Icons.storefront_outlined,
                    label: 'Recherche',
                  ),
                  SizedBox(width: 56),
                  _BottomNavItem(
                    icon: Icons.shopping_basket_outlined,
                    label: 'Réservations',
                  ),
                  _BottomNavItem(
                    icon: Icons.person_outline,
                    label: 'Profil',
                  ),
                ],
              ),
              Positioned(
                left: 167,
                top: -15,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFBBF7D0).withValues(alpha: 0.9),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child:
                      const Icon(Icons.add, color: AppColors.white, size: 28),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF4CAF50) : const Color(0xFF9CA3AF);

    return SizedBox(
      width: 62,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w400,
              height: 1.15,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
