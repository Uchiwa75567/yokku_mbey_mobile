import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../buyer_needs/presentation/pages/publish_buyer_need_page.dart';
import '../../../buyer_products/presentation/pages/buyer_product_detail_page.dart';
import '../../../buyer_products/presentation/pages/buyer_products_page.dart';
import '../../../buyer_purchases/presentation/pages/buyer_purchases_page.dart';
import '../../../home/presentation/widgets/buyer_bottom_navigation.dart';
import '../../../buyer_profile/presentation/pages/buyer_profile_page.dart';
import 'buyer_alert_detail_page.dart';

enum _FavoritesTab { favorites, priceAlerts, producers }

class BuyerFavoritesPage extends StatefulWidget {
  const BuyerFavoritesPage({super.key});

  static const String routeName = '/buyer-favorites';

  @override
  State<BuyerFavoritesPage> createState() => _BuyerFavoritesPageState();
}

class _BuyerFavoritesPageState extends State<BuyerFavoritesPage> {
  _FavoritesTab _selectedTab = _FavoritesTab.favorites;
  final List<_FavoriteProduct> _favorites = List.of(_initialFavorites);

  void _openProduct(_FavoriteProduct product) {
    Navigator.of(context).pushNamed(
      BuyerProductDetailPage.routeName,
      arguments: BuyerProductDetailData(
        imageAsset: product.imageAsset,
        name: product.name,
        priceLabel: '${product.price} FCFA / kg',
        unitPrice: product.price,
        location: product.location,
      ),
    );
  }

  void _removeFavorite(_FavoriteProduct product) {
    final index = _favorites.indexOf(product);
    setState(() => _favorites.remove(product));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.name} retiré des favoris'),
          action: SnackBarAction(
            label: 'Annuler',
            onPressed: () {
              setState(() => _favorites.insert(index, product));
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _FavoritesHeader()),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabsHeaderDelegate(
                selectedTab: _selectedTab,
                onChanged: (tab) => setState(() => _selectedTab = tab),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 108 + bottomInset),
              sliver: _buildContent(),
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
                  activeTab: BuyerNavigationTab.home,
                  onHome: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  onSearch: () => Navigator.of(
                    context,
                  ).pushNamed(BuyerProductsPage.routeName),
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
    );
  }

  Widget _buildContent() {
    return switch (_selectedTab) {
      _FavoritesTab.favorites => _favorites.isEmpty
          ? const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyFavorites(),
            )
          : SliverList.separated(
              itemCount: _favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final product = _favorites[index];
                return _FavoriteProductCard(
                  product: product,
                  onOpen: () => _openProduct(product),
                  onRemove: () => _removeFavorite(product),
                );
              },
            ),
      _FavoritesTab.priceAlerts => const SliverList(
          delegate: SliverChildListDelegate.fixed([
            _PriceAlertCard(
              product: 'Tomate fraîche',
              targetPrice: '350 FCFA/kg',
              currentPrice: '400 FCFA/kg',
              enabled: true,
            ),
            SizedBox(height: 18),
            _PriceAlertCard(
              product: 'Oignon local',
              targetPrice: '300 FCFA/kg',
              currentPrice: '350 FCFA/kg',
              enabled: true,
            ),
          ]),
        ),
      _FavoritesTab.producers => const SliverList(
          delegate: SliverChildListDelegate.fixed([
            _ProducerCard(
              initials: 'IN',
              name: 'Ibrahima Ndiaye',
              location: 'Nioro du Rip, Kaolack',
              rating: '4,8',
            ),
            SizedBox(height: 18),
            _ProducerCard(
              initials: 'AD',
              name: 'Awa Diop',
              location: 'Louga',
              rating: '4,7',
            ),
          ]),
        ),
    };
  }
}

class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF087C2E),
      padding: const EdgeInsets.fromLTRB(47, 72, 30, 30),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Favoris et alertes',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Retrouvez vos produits suivis',
            style: TextStyle(color: Color(0xFFE3F4E8), fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _TabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _TabsHeaderDelegate({
    required this.selectedTab,
    required this.onChanged,
  });

  final _FavoritesTab selectedTab;
  final ValueChanged<_FavoritesTab> onChanged;

  @override
  double get minExtent => 73;

  @override
  double get maxExtent => 73;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
        child: Row(
          children: [
            _TabButton(
              label: 'Favoris',
              selected: selectedTab == _FavoritesTab.favorites,
              onTap: () => onChanged(_FavoritesTab.favorites),
            ),
            const SizedBox(width: 8),
            _TabButton(
              label: 'Alertes prix',
              selected: selectedTab == _FavoritesTab.priceAlerts,
              onTap: () => onChanged(_FavoritesTab.priceAlerts),
            ),
            const SizedBox(width: 8),
            _TabButton(
              label: 'Producteurs suivis',
              selected: selectedTab == _FavoritesTab.producers,
              onTap: () => onChanged(_FavoritesTab.producers),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_TabsHeaderDelegate oldDelegate) {
    return oldDelegate.selectedTab != selectedTab;
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
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
        height: 43,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            foregroundColor:
                selected ? const Color(0xFF06723B) : const Color(0xFF697386),
            backgroundColor:
                selected ? const Color(0xFFF0F8F4) : AppColors.white,
            side: BorderSide(
              color:
                  selected ? const Color(0xFF06723B) : const Color(0xFFE6E9EE),
              width: selected ? 2 : 1,
            ),
            shape: const StadiumBorder(),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteProductCard extends StatelessWidget {
  const _FavoriteProductCard({
    required this.product,
    required this.onOpen,
    required this.onRemove,
  });

  final _FavoriteProduct product;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 158,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 104,
            height: 118,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: product.tint,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: product.borderColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(product.imageAsset, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Retirer des favoris',
                      onPressed: onRemove,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      icon: const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFFF0444B),
                        size: 26,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${product.price} FCFA/kg',
                  style: const TextStyle(
                    color: Color(0xFF06723B),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.location,
                  style: const TextStyle(
                    color: Color(0xFFA0A8B6),
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: onOpen,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(115, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: const Color(0xFF06723B),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Voir le produit',
                    style: TextStyle(fontWeight: FontWeight.w700),
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

class _PriceAlertCard extends StatefulWidget {
  const _PriceAlertCard({
    required this.product,
    required this.targetPrice,
    required this.currentPrice,
    required this.enabled,
  });

  final String product;
  final String targetPrice;
  final String currentPrice;
  final bool enabled;

  @override
  State<_PriceAlertCard> createState() => _PriceAlertCardState();
}

class _PriceAlertCardState extends State<_PriceAlertCard> {
  late bool enabled = widget.enabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: AppColors.white,
      child: ListTile(
        onTap: () => Navigator.of(context).pushNamed(
          BuyerAlertDetailPage.routeName,
        ),
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFF3E5),
          child:
              Icon(Icons.notifications_active_outlined, color: Colors.orange),
        ),
        title: Text(
          widget.product,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          'Alerte à ${widget.targetPrice}\nPrix actuel : ${widget.currentPrice}',
        ),
        trailing: Switch(
          value: enabled,
          activeThumbColor: const Color(0xFF06723B),
          onChanged: (value) => setState(() => enabled = value),
        ),
      ),
    );
  }
}

class _ProducerCard extends StatelessWidget {
  const _ProducerCard({
    required this.initials,
    required this.name,
    required this.location,
    required this.rating,
  });

  final String initials;
  final String name;
  final String location;
  final String rating;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: AppColors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE7F6ED),
          child: Text(
            initials,
            style: const TextStyle(
              color: Color(0xFF06723B),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(location),
        trailing: Text(
          '$rating ★',
          style: const TextStyle(
            color: Color(0xFFF59E0B),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border_rounded,
              size: 48, color: Color(0xFFA0A8B6)),
          SizedBox(height: 12),
          Text(
            'Aucun produit favori',
            style: TextStyle(
              color: Color(0xFF697386),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteProduct {
  const _FavoriteProduct({
    required this.name,
    required this.price,
    required this.location,
    required this.imageAsset,
    required this.tint,
    required this.borderColor,
  });

  final String name;
  final int price;
  final String location;
  final String imageAsset;
  final Color tint;
  final Color borderColor;
}

const _initialFavorites = [
  _FavoriteProduct(
    name: 'Tomate fraîche',
    price: 400,
    location: 'Kaolack',
    imageAsset: AppAssets.buyerTomato,
    tint: Color(0xFFFFF4E8),
    borderColor: Color(0xFFFFDCB4),
  ),
  _FavoriteProduct(
    name: 'Oignon local',
    price: 350,
    location: 'Louga',
    imageAsset: AppAssets.buyerOnion,
    tint: Color(0xFFFFFAEC),
    borderColor: Color(0xFFFFE995),
  ),
  _FavoriteProduct(
    name: 'Pomme de terre',
    price: 500,
    location: 'Saint-Louis',
    imageAsset: AppAssets.buyerPotato,
    tint: Color(0xFFF1FFF7),
    borderColor: Color(0xFFC9F6DB),
  ),
];
