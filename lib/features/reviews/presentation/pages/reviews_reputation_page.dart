import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/journey_scaffold.dart';

class ReviewsReputationPage extends StatelessWidget {
  const ReviewsReputationPage({super.key});
  static const String routeName = '/reviews-reputation';
  @override
  Widget build(BuildContext context) =>
      const JourneyScaffold(title: 'Avis et réputation', children: [
        JourneyNotice(
            'Exemples d’avis et de notes, présentés pour la démonstration.'),
        _GlobalRatingCard(),
        Divider(),
        JourneyHeading('Détails'),
        _RatingDetail(label: 'Qualité des produits', rating: '4,9'),
        _RatingDetail(label: 'Respect des quantités', rating: '4,8'),
        _RatingDetail(label: 'Ponctualité', rating: '4,6'),
        _RatingDetail(label: 'Communication', rating: '4,9'),
        Divider(),
        JourneyHeading('Derniers avis'),
        _ReviewCard(
            author: 'Marché Central Dakar',
            rating: '5,0',
            comment: 'Très bon produit et quantité respectée.'),
        _ReviewCard(
            author: 'Restaurant Teranga',
            rating: '4,2',
            comment: 'Livraison un peu tardive mais produit frais.'),
      ]);
}

class _GlobalRatingCard extends StatelessWidget {
  const _GlobalRatingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 157,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
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
        borderRadius: BorderRadius.circular(8),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 18, 15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
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
