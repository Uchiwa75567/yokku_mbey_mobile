import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../harvest_boost/presentation/pages/harvest_boost_page.dart';
import '../../../harvest_edit/presentation/pages/harvest_edit_page.dart';
import '../../../home/presentation/widgets/farmer_glass_surface.dart';

class HarvestDetailPage extends StatefulWidget {
  const HarvestDetailPage({super.key});

  static const String routeName = '/harvest-detail';

  @override
  State<HarvestDetailPage> createState() => _HarvestDetailPageState();
}

class _HarvestDetailPageState extends State<HarvestDetailPage> {
  static const String _listingLink =
      'https://yokkumbey.sn/recoltes/tomate-fraiche';

  bool _isFavorite = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _copyListingLink() async {
    await Clipboard.setData(const ClipboardData(text: _listingLink));
    if (mounted) {
      _showMessage('Lien de l’annonce copié');
    }
  }

  Future<void> _shareListing() async {
    await Clipboard.setData(const ClipboardData(text: _listingLink));
    if (mounted) {
      _showMessage('Lien prêt à être partagé');
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
        backgroundColor: const Color(0xFF18241D),
        body: LayoutBuilder(
          builder: (context, constraints) {
            const designWidth = 440.0;
            const designHeight = 956.0;
            final scale = (constraints.maxWidth / designWidth).clamp(0.1, 1.0);
            final scaledWidth = designWidth * scale;
            final scaledHeight = designHeight * scale;

            return Center(
              child: SizedBox(
                width: scaledWidth,
                height: constraints.maxHeight,
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: scaledWidth,
                    height: scaledHeight,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: designWidth,
                        height: designHeight,
                        child: _HarvestDetailCanvas(
                          isFavorite: _isFavorite,
                          onBack: () => Navigator.of(context).maybePop(),
                          onFavorite: () {
                            setState(() => _isFavorite = !_isFavorite);
                          },
                          onShare: _shareListing,
                          onCopyLink: _copyListingLink,
                          onModify: () {
                            Navigator.of(context).pushNamed(
                              HarvestEditPage.routeName,
                              arguments: HarvestEditPage.defaultHarvest,
                            );
                          },
                          onBoost: () {
                            Navigator.of(context).pushNamed(
                              HarvestBoostPage.routeName,
                              arguments: HarvestBoostPage.defaultHarvest,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HarvestDetailCanvas extends StatelessWidget {
  const _HarvestDetailCanvas({
    required this.isFavorite,
    required this.onBack,
    required this.onFavorite,
    required this.onShare,
    required this.onCopyLink,
    required this.onModify,
    required this.onBoost,
  });

  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final VoidCallback onShare;
  final VoidCallback onCopyLink;
  final VoidCallback onModify;
  final VoidCallback onBoost;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF18241D),
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 285,
            child: Image(
              image: AssetImage(AppAssets.harvestTomatoDetail),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 22,
            top: 70,
            child: _RoundActionButton(
              icon: Icons.chevron_left,
              iconSize: 34,
              onTap: onBack,
            ),
          ),
          Positioned(
            right: 70,
            top: 70,
            child: _RoundActionButton(
              icon: isFavorite ? Icons.favorite : Icons.favorite_border,
              iconColor: isFavorite ? const Color(0xFFE53935) : null,
              onTap: onFavorite,
            ),
          ),
          Positioned(
            right: 16,
            top: 70,
            child: _RoundActionButton(
              icon: Icons.share_outlined,
              onTap: onShare,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 248,
            child: SizedBox(
              height: 708,
              child: FarmerGlassSurface(
                color: const Color(0xE6FFFFFF),
                blurSigma: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                borderColor: const Color(0x66FFFFFF),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TitleSection(onCopyLink: onCopyLink),
                      const SizedBox(height: 20),
                      const _HarvestInformation(),
                      const SizedBox(height: 24),
                      const _DescriptionSection(),
                      const SizedBox(height: 26),
                      const Text(
                        'Performance',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _PerformanceCard(),
                      const Spacer(),
                      _BottomActions(onModify: onModify, onBoost: onBoost),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.iconSize = 26,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 48,
      child: Material(
        color: AppColors.white.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.16),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Icon(
            icon,
            color: iconColor ?? const Color(0xFF394457),
            size: iconSize,
          ),
        ),
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection({required this.onCopyLink});

  final VoidCallback onCopyLink;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Tomate fraîche',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Copier le lien',
              onPressed: onCopyLink,
              icon: const Icon(
                Icons.link,
                color: Color(0xFF9AA5B5),
                size: 24,
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: Color(0xFF9AA5B5),
              size: 28,
            ),
          ],
        ),
        const SizedBox(height: 7),
        const Row(
          children: [
            Expanded(
              child: Text(
                '350 FCFA / kg',
                style: TextStyle(
                  color: Color(0xFF138A3D),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
            _AvailabilityBadge(),
          ],
        ),
      ],
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE8FAF2),
        borderRadius: BorderRadius.circular(99),
      ),
      child: const Text(
        'Disponible',
        style: TextStyle(
          color: Color(0xFF087C60),
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _HarvestInformation extends StatelessWidget {
  const _HarvestInformation();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _InformationRow(
          icon: Icons.inventory_2_outlined,
          label: 'Quantité disponible',
          value: '500 kg • Min 50 kg',
        ),
        SizedBox(height: 17),
        _InformationRow(
          icon: Icons.location_on_outlined,
          label: 'Région',
          value: 'Nioro du Rip, Kaolack',
        ),
        SizedBox(height: 17),
        _InformationRow(
          icon: Icons.calendar_month_outlined,
          label: 'Disponibilité',
          value: 'Maintenant',
        ),
        SizedBox(height: 17),
        _InformationRow(
          icon: Icons.category_outlined,
          label: 'Catégorie',
          value: 'Légumes',
        ),
        SizedBox(height: 17),
        _InformationRow(
          label: 'Réservations',
          value: 'Autorisées',
        ),
      ],
    );
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.label,
    required this.value,
    this.icon,
  });

  final IconData? icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 33,
          child: icon == null
              ? null
              : Icon(icon, color: const Color(0xFF394457), size: 24),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF3F495B),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(
            Icons.info_outline,
            color: Color(0xFF394457),
            size: 24,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Description',
                style: TextStyle(
                  color: Color(0xFF3F495B),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tomates fraîches, bien mûries, idéales pour\ntout usage.',
                style: TextStyle(
                  color: Color(0xFF5D687A),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8EDF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        children: [
          Expanded(child: _PerformanceMetric(label: 'VUES', value: '320')),
          _VerticalDivider(),
          Expanded(
            child: _PerformanceMetric(label: 'RÉSERVATIONS', value: '18'),
          ),
          _VerticalDivider(),
          Expanded(
              child: _PerformanceMetric(label: 'VENDUES', value: '240 kg')),
        ],
      ),
    );
  }
}

class _PerformanceMetric extends StatelessWidget {
  const _PerformanceMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF9AA8BD),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 48,
      child: VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE8EDF3)),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.onModify, required this.onBoost});

  final VoidCallback onModify;
  final VoidCallback onBoost;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 54,
            child: OutlinedButton(
              onPressed: onModify,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF138A3D),
                side: const BorderSide(color: Color(0xFF138A3D), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              child: const Text('Modifier'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: onBoost,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF007A00),
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              child: const Text(
                'Booster l’annonce',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
