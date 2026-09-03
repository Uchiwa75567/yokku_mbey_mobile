import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../buyer_purchases/presentation/pages/buyer_purchases_page.dart';
import '../../../buyer_support/presentation/pages/buyer_action_success_page.dart';

class BuyerRateTransactionArguments {
  const BuyerRateTransactionArguments({
    required this.productName,
    required this.quantityKg,
    this.producerName = 'Ibrahima Ndiaye',
  });

  final String productName;
  final int quantityKg;
  final String producerName;
}

class BuyerRateTransactionPage extends StatefulWidget {
  const BuyerRateTransactionPage({super.key, required this.arguments});

  static const String routeName = '/buyer-rate-transaction';

  final BuyerRateTransactionArguments arguments;

  static Widget fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return BuyerRateTransactionPage(
      arguments: arguments is BuyerRateTransactionArguments
          ? arguments
          : const BuyerRateTransactionArguments(
              productName: 'Tomate fraîche',
              quantityKg: 200,
            ),
    );
  }

  @override
  State<BuyerRateTransactionPage> createState() =>
      _BuyerRateTransactionPageState();
}

class _BuyerRateTransactionPageState extends State<BuyerRateTransactionPage> {
  final _commentController = TextEditingController();
  int _rating = 5;

  final Map<String, String> _criteria = {
    'Qualité du produit': 'Très bonne',
    'Respect de la quantité': 'Conforme',
    'Ponctualité': "À l'heure",
    'Communication': 'Très bonne',
  };

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    FocusScope.of(context).unfocus();
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => BuyerActionSuccessPage(
          arguments: BuyerActionSuccessArguments(
            title: 'Merci pour votre avis !',
            message: 'Votre note de $_rating/5 a été publiée.',
            buttonLabel: 'Retour à mes achats',
            destinationRoute: BuyerPurchasesPage.routeName,
            icon: Icons.star_rounded,
          ),
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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            const SliverToBoxAdapter(child: _RatingHeader()),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(32, 34, 32, 28 + bottomInset),
              sliver: SliverList.list(
                children: [
                  Text(
                    '${widget.arguments.productName} • '
                    '${widget.arguments.quantityKg} kg',
                    style: const TextStyle(
                      color: Color(0xFF172748),
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Producteur : ${widget.arguments.producerName}',
                    style: const TextStyle(
                      color: Color(0xFF697386),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 42),
                  const Center(
                    child: Text(
                      'Quelle est votre note ?',
                      style: TextStyle(
                        color: Color(0xFF172748),
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final value = index + 1;
                      return IconButton(
                        tooltip: '$value étoile${value > 1 ? 's' : ''}',
                        onPressed: () => setState(() => _rating = value),
                        icon: Icon(
                          value <= _rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFFFB51B),
                          size: 38,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 36),
                  for (final entry in _criteria.entries) ...[
                    _CriterionTile(
                      label: entry.key,
                      value: entry.value,
                      onTap: () => _editCriterion(entry.key),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 12),
                  const Text(
                    'Commentaire',
                    style: TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _commentController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Partagez votre expérience...',
                      hintStyle: const TextStyle(
                        color: Color(0xFFA0A8B6),
                        fontStyle: FontStyle.italic,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFDDE2E8),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFDDE2E8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: _publish,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(58),
                      backgroundColor: const Color(0xFF075D34),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Publier mon avis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
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

  Future<void> _editCriterion(String criterion) async {
    const options = ['Très bonne', 'Conforme', "À l'heure", 'À améliorer'];
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in options)
              ListTile(
                title: Text(option),
                trailing: _criteria[criterion] == option
                    ? const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF087C2E),
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(option),
              ),
          ],
        ),
      ),
    );
    if (selected != null) {
      setState(() => _criteria[criterion] = selected);
    }
  }
}

class _RatingHeader extends StatelessWidget {
  const _RatingHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF087C2E),
      padding: const EdgeInsets.fromLTRB(18, 58, 24, 32),
      child: Row(
        children: [
          IconButton.filled(
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Noter la transaction',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Votre avis renforce la confiance',
                  style: TextStyle(
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

class _CriterionTile extends StatelessWidget {
  const _CriterionTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F9FB),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF62748E),
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF172748),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
