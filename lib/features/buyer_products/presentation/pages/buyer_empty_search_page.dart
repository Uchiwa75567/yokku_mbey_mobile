import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../buyer_favorites/presentation/pages/buyer_create_alert_page.dart';
import '../../../buyer_needs/presentation/pages/publish_buyer_need_page.dart';

class BuyerEmptySearchArguments {
  const BuyerEmptySearchArguments({
    this.query = 'Tomate',
    this.location = 'Dakar',
  });

  final String query;
  final String location;
}

class BuyerEmptySearchPage extends StatelessWidget {
  const BuyerEmptySearchPage({super.key, required this.arguments});

  static const String routeName = '/buyer-empty-search';

  final BuyerEmptySearchArguments arguments;

  static Widget fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return BuyerEmptySearchPage(
      arguments: arguments is BuyerEmptySearchArguments
          ? arguments
          : const BuyerEmptySearchArguments(),
    );
  }

  void _createAlert(BuildContext context) {
    Navigator.of(context).pushNamed(
      BuyerCreateAlertPage.routeName,
      arguments: BuyerCreateAlertArguments(
        product: arguments.query,
        region: arguments.location,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final queryLabel = '${arguments.query} à ${arguments.location}';

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
              child: _SearchHeader(arguments: arguments),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(32, 24, 32, 28 + bottomInset),
                child: Column(
                  children: [
                    Container(
                      height: 55,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFDDE2E8)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF98A2B3),
                            size: 27,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              queryLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF344054),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 2),
                    Container(
                      width: 128,
                      height: 128,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEDF7F1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.find_in_page_outlined,
                        color: Color(0xFF076735),
                        size: 52,
                      ),
                    ),
                    const SizedBox(height: 34),
                    const Text(
                      'Aucun produit trouvé',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF062B57),
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Modifiez vos filtres ou publiez une\ndemande d'achat.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF71829D),
                        fontSize: 16,
                        height: 1.45,
                      ),
                    ),
                    const Spacer(flex: 3),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pushNamed(
                        PublishBuyerNeedPage.routeName,
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        backgroundColor: const Color(0xFF076735),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Publier une demande',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        foregroundColor: const Color(0xFF076735),
                        side: const BorderSide(color: Color(0xFF076735)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Modifier les filtres',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => _createAlert(context),
                      child: const Text(
                        'Créer une alerte de prix',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({required this.arguments});

  final BuyerEmptySearchArguments arguments;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF087C2E),
      padding: const EdgeInsets.fromLTRB(18, 58, 24, 32),
      child: Row(
        children: [
          IconButton.filled(
            tooltip: 'Retour',
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              fixedSize: const Size(48, 48),
              backgroundColor: Colors.white.withValues(alpha: 0.3),
            ),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Résultats de recherche',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${arguments.query} • ${arguments.location}',
                  style: const TextStyle(
                    color: Color(0xFFE3F4E8),
                    fontSize: 16,
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
