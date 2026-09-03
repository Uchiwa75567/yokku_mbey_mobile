import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/farmer_glass_surface.dart';

class ReviewsReputationPage extends StatelessWidget {
  const ReviewsReputationPage({super.key});

  static const String routeName = '/reviews-reputation';
  static const double _designWidth = 440;
  static const double _designHeight = 956;

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

            return Center(
              child: SizedBox(
                width: scaledWidth,
                height: constraints.maxHeight,
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: scaledWidth,
                    height: scaledHeight,
                    child: const FittedBox(
                      fit: BoxFit.fill,
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: _designWidth,
                        height: _designHeight,
                        child: _ReviewsCanvas(),
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

class _ReviewsCanvas extends StatelessWidget {
  const _ReviewsCanvas();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned.fill(
          child: FarmerGlassBackground(overlayOpacity: 0.46),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 201,
          child: FarmerGlassSurface(
            color: Color(0x1AFFFFFF),
            blurSigma: 16,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(26),
            ),
            borderColor: Color(0x33FFFFFF),
            child: SizedBox.expand(),
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          top: 185,
          bottom: 18,
          child: FarmerGlassSurface(
            color: Color(0xE6FFFFFF),
            blurSigma: 20,
            borderRadius: BorderRadius.all(Radius.circular(28)),
            borderColor: Color(0x66FFFFFF),
            child: SizedBox.expand(),
          ),
        ),
        Positioned(
          left: 54,
          right: 40,
          top: 68,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Avis et réputation',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 9),
              Text(
                'Votre crédibilité sur YOKKU',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 46,
          right: 36,
          top: 139,
          child: _GlobalRatingCard(),
        ),
        Positioned(
          left: 51,
          top: 321,
          child: Text(
            'Détails',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        Positioned(
          left: 48,
          right: 34,
          top: 360,
          child: Column(
            children: [
              _RatingDetail(label: 'Qualité des produits', rating: '4,9'),
              SizedBox(height: 13),
              _RatingDetail(label: 'Respect des quantités', rating: '4,8'),
              SizedBox(height: 13),
              _RatingDetail(label: 'Ponctualité', rating: '4,6'),
              SizedBox(height: 13),
              _RatingDetail(label: 'Communication', rating: '4,9'),
            ],
          ),
        ),
        Positioned(
          left: 48,
          top: 647,
          child: Text(
            'Derniers avis',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        Positioned(
          left: 44,
          right: 38,
          top: 684,
          child: Column(
            children: [
              _ReviewCard(
                author: 'Marché Central Dakar',
                rating: '5,0',
                comment: 'Très bon produit et quantité respectée.',
              ),
              SizedBox(height: 17),
              _ReviewCard(
                author: 'Restaurant Teranga',
                rating: '4,2',
                comment: 'Livraison un peu tardive mais produit frais.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlobalRatingCard extends StatelessWidget {
  const _GlobalRatingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 157,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '4,8',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 52,
              fontWeight: FontWeight.w800,
              height: 0.95,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 13),
          _RatingStars(),
          SizedBox(height: 8),
          Text(
            '32 avis',
            style: TextStyle(
              color: Color(0xFFA1AAB9),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (_) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            Icons.star,
            color: Color(0xFFF59800),
            size: 27,
          ),
        ),
      ),
    );
  }
}

class _RatingDetail extends StatelessWidget {
  const _RatingDetail({required this.label, required this.rating});

  final String label;
  final String rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 53,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFF0F2F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$rating ★',
            style: const TextStyle(
              color: Color(0xFFFF8A3D),
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.author,
    required this.rating,
    required this.comment,
  });

  final String author;
  final String rating;
  final String comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.fromLTRB(20, 20, 18, 15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF0F2F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                  author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$rating ★',
                style: const TextStyle(
                  color: Color(0xFFFF8A3D),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            comment,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6B7C95),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
