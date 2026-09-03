import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../buyer_favorites/presentation/pages/buyer_favorites_page.dart';
import '../../../buyer_needs/presentation/pages/buyer_needs_page.dart';
import '../../../buyer_needs/presentation/pages/publish_buyer_need_page.dart';
import '../../../buyer_products/presentation/pages/buyer_products_page.dart';
import '../../../buyer_purchases/presentation/pages/buyer_purchases_page.dart';
import '../../../home/presentation/widgets/buyer_bottom_navigation.dart';
import '../../../buyer_payments/presentation/pages/buyer_payment_history_page.dart';
import '../../../buyer_payments/presentation/pages/buyer_saved_payment_methods_page.dart';
import '../../../buyer_notifications/presentation/pages/buyer_notifications_page.dart';
import 'buyer_account_pages.dart';
import 'buyer_delivery_addresses_page.dart';

class BuyerProfilePage extends StatelessWidget {
  const BuyerProfilePage({super.key});

  static const String routeName = '/buyer-profile';

  void _open(BuildContext context, String routeName) {
    Navigator.of(context).pushNamed(routeName);
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
            SliverToBoxAdapter(
              child: _ProfileHero(
                onNotifications: () =>
                    _open(context, BuyerNotificationsPage.routeName),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(52, 36, 42, 110 + bottomInset),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  _ProfileMenuItem(
                    icon: Icons.badge_outlined,
                    label: 'Informations personnelles',
                    onTap: () =>
                        _open(context, BuyerPersonalInfoPage.routeName),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Mes achats',
                    onTap: () => _open(context, BuyerPurchasesPage.routeName),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.location_on_outlined,
                    label: 'Mes demandes',
                    onTap: () => _open(context, BuyerNeedsPage.routeName),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.favorite_border_rounded,
                    label: 'Favoris et alertes',
                    onTap: () => _open(context, BuyerFavoritesPage.routeName),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.local_shipping_outlined,
                    label: 'Adresses de livraison',
                    onTap: () => _open(
                      context,
                      BuyerDeliveryAddressesPage.routeName,
                    ),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Paiements',
                    onTap: () =>
                        _open(context, BuyerPaymentHistoryPage.routeName),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.credit_card_outlined,
                    label: 'Moyens de paiement',
                    onTap: () => _open(
                      context,
                      BuyerSavedPaymentMethodsPage.routeName,
                    ),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.star_outline_rounded,
                    label: 'Avis et réputation',
                    onTap: () => _open(context, BuyerReputationPage.routeName),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.settings_outlined,
                    label: 'Paramètres',
                    onTap: () => _open(context, BuyerSettingsPage.routeName),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Aide et support',
                    onTap: () => _open(context, BuyerHelpSupportPage.routeName),
                  ),
                ]),
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
                  activeTab: BuyerNavigationTab.profile,
                  onHome: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  onSearch: () => _open(context, BuyerProductsPage.routeName),
                  onPrimaryAction: () =>
                      _open(context, PublishBuyerNeedPage.routeName),
                  onReservations: () =>
                      _open(context, BuyerPurchasesPage.routeName),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.onNotifications});

  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 351,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 287,
            width: double.infinity,
            color: const Color(0xFF087C18),
          ),
          Positioned(
            right: 22,
            top: 74,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: onNotifications,
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.white,
                    size: 30,
                  ),
                ),
                Positioned(
                  right: 7,
                  top: 5,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0444B),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 54,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7C928),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      AppAssets.farmerProfile,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Awa DIOP',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Acheteuse vérifiée • Dakar',
                  style: TextStyle(
                    color: Color(0xFFE5F5E8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 17,
            right: 17,
            top: 242,
            child: _ProfileStats(),
          ),
        ],
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 109,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Row(
        children: [
          Expanded(child: _Stat(value: '18', label: 'Achats')),
          _StatDivider(),
          Expanded(child: _Stat(value: '4', label: 'Demandes')),
          _StatDivider(),
          Expanded(child: _Stat(value: '4,9', label: 'Note')),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Color(0xFF697386))),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 40,
      child: VerticalDivider(color: Color(0xFFE8EBEF)),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF526071), size: 23),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF39475B),
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9CA6B3),
            ),
          ],
        ),
      ),
    );
  }
}
