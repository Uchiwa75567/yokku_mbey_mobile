import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/external_contact_service.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/buyer_bottom_navigation.dart';
import '../../../buyer_purchases/presentation/pages/buyer_purchases_page.dart';
import '../../../buyer_needs/presentation/pages/publish_buyer_need_page.dart';
import '../../../buyer_profile/presentation/pages/buyer_profile_page.dart';
import 'pre_reservation_page.dart';
import 'product_reservation_page.dart';

class BuyerProductDetailData {
  const BuyerProductDetailData({
    required this.imageAsset,
    required this.name,
    required this.priceLabel,
    required this.location,
    this.quantityLabel = '500 kg disponibles • minimum 50 kg',
    this.recoveryMode = 'Retrait producteur',
    this.description =
        'Produit frais cultivé sans produits chimiques, idéal pour toutes vos préparations.',
    this.availableSoon = false,
    this.unitPrice = 400,
    this.availabilityLabel = 'Disponible entre le 15 et le 25 juillet',
    this.depositPercentage = 20,
    this.producerName = 'Ibrahima NDIAYE',
    this.contactPhone = '+221 77 000 00 00',
  });

  final String imageAsset;
  final String name;
  final String priceLabel;
  final String location;
  final String quantityLabel;
  final String recoveryMode;
  final String description;
  final bool availableSoon;
  final int unitPrice;
  final String availabilityLabel;
  final int depositPercentage;
  final String producerName;
  final String contactPhone;
}

class BuyerProductDetailPage extends StatelessWidget {
  const BuyerProductDetailPage({
    this.product = defaultProduct,
    super.key,
  });

  static const String routeName = '/buyer-product-detail';
  static const double _designWidth = 440;
  static const double _designHeight = 1070;

  static const BuyerProductDetailData defaultProduct = BuyerProductDetailData(
    imageAsset: AppAssets.buyerTomato,
    name: 'Tomate fraîche',
    priceLabel: '400 FCFA / kg',
    location: 'Nioro du Rip, Kaolack',
    description:
        'Tomate fraîche cultivée sans produits chimiques, idéale pour toutes préparations.',
  );

  final BuyerProductDetailData product;

  static BuyerProductDetailPage fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return BuyerProductDetailPage(
      product: arguments is BuyerProductDetailData ? arguments : defaultProduct,
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  Future<void> _share(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(
        text:
            '${product.name} à ${product.priceLabel} sur YOKKU — ${product.location}',
      ),
    );
    if (context.mounted) {
      _showMessage(context, 'Lien du produit copié');
    }
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
            final scale = constraints.maxWidth / _designWidth;
            final scaledWidth = constraints.maxWidth;
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
                            child: _ProductDetailCanvas(
                              product: product,
                              onBack: () => Navigator.of(context).pop(),
                              onShare: () => _share(context),
                              onReserve: () {
                                if (product.availableSoon) {
                                  Navigator.of(context).pushNamed(
                                    PreReservationPage.routeName,
                                    arguments: PreReservationData(
                                      productName: product.name,
                                      unitPrice: product.unitPrice,
                                      availabilityLabel:
                                          product.availabilityLabel,
                                      depositPercentage:
                                          product.depositPercentage,
                                      recoveryMode: product.recoveryMode,
                                    ),
                                  );
                                  return;
                                }
                                Navigator.of(context).pushNamed(
                                  ProductReservationPage.routeName,
                                  arguments: ProductReservationData(
                                    productName: product.name,
                                    unitPrice: product.unitPrice,
                                    quantityLabel: product.quantityLabel,
                                    recoveryMode: product.recoveryMode,
                                    depositPercentage:
                                        product.depositPercentage,
                                  ),
                                );
                              },
                              onContact: () =>
                                  ExternalContactService.showContactOptions(
                                context,
                                phoneNumber: product.contactPhone,
                                contactName: product.producerName,
                                message:
                                    'Bonjour, je suis intéressé par ${product.name} publié sur YOKKU MBEY.',
                              ),
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
                            activeTab: BuyerNavigationTab.search,
                            onPrimaryAction: () => Navigator.of(
                              context,
                            ).pushNamed(PublishBuyerNeedPage.routeName),
                            onHome: () => Navigator.of(context).popUntil(
                              (route) => route.isFirst,
                            ),
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

class _ProductDetailCanvas extends StatelessWidget {
  const _ProductDetailCanvas({
    required this.product,
    required this.onBack,
    required this.onShare,
    required this.onReserve,
    required this.onContact,
  });

  final BuyerProductDetailData product;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onReserve;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.white,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 294,
            child: Image.asset(
              product.imageAsset,
              key: const ValueKey('product-detail-hero-image'),
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 10,
            top: 60,
            child: _RoundAction(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBack,
            ),
          ),
          Positioned(
            right: 10,
            top: 60,
            child: _RoundAction(
              icon: Icons.share_outlined,
              onTap: onShare,
            ),
          ),
          Positioned(
            left: 14,
            right: 11,
            top: 255,
            child: Container(
              height: 635,
              padding: const EdgeInsets.fromLTRB(25, 26, 22, 20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
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
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _AvailabilityBadge(
                        availableSoon: product.availableSoon,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.priceLabel,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    product.quantityLabel,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Producteur',
                    style: TextStyle(
                      color: Color(0xFF687284),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _ProducerCard(),
                  const SizedBox(height: 17),
                  _DetailRow(label: 'Localisation', value: product.location),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Mode de récupération',
                    value: product.recoveryMode,
                  ),
                  const SizedBox(height: 23),
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Text(
                    product.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF566273),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: onReserve,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(57),
                      backgroundColor: const Color(0xFF087C12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: Text(
                      product.availableSoon
                          ? 'Pré-réserver ce produit'
                          : 'Réserver ce produit',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 36,
            right: 36,
            top: 915,
            child: OutlinedButton(
              onPressed: onContact,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(55),
                foregroundColor: const Color(0xFF087C12),
                side: const BorderSide(color: Color(0xFF087C12)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: const Text('Appeler ou WhatsApp'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.38),
        fixedSize: const Size(42, 42),
      ),
      icon: Icon(icon, color: AppColors.white, size: 22),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.availableSoon});

  final bool availableSoon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F0),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        availableSoon ? 'À venir' : 'Disponible',
        style: const TextStyle(
          color: Color(0xFF087C4A),
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ProducerCard extends StatelessWidget {
  const _ProducerCard();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 62,
          height: 62,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE4E7EB)),
          ),
          child: ClipOval(
            child: Image.asset(AppAssets.farmerProfile, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ibrahima NDIAYE',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Producteur vérifié • 4,8 ★',
                style: TextStyle(
                  color: Color(0xFF087C12),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4B5668),
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
