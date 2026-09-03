import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import 'buyer_issue_detail_page.dart';

class BuyerReportProblemArguments {
  const BuyerReportProblemArguments({
    this.reference = 'Commande YK-2026-0184',
  });

  final String reference;
}

class BuyerReportProblemPage extends StatefulWidget {
  const BuyerReportProblemPage({super.key, required this.arguments});

  static const String routeName = '/buyer-report-problem';

  final BuyerReportProblemArguments arguments;

  static Widget fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return BuyerReportProblemPage(
      arguments: arguments is BuyerReportProblemArguments
          ? arguments
          : const BuyerReportProblemArguments(),
    );
  }

  @override
  State<BuyerReportProblemPage> createState() => _BuyerReportProblemPageState();
}

class _BuyerReportProblemPageState extends State<BuyerReportProblemPage> {
  final _descriptionController = TextEditingController();
  int _selectedReason = 0;
  int _evidenceCount = 0;
  bool _submitting = false;

  static const _reasons = [
    'Produit non conforme',
    'Quantité incorrecte',
    'Retard important',
    'Producteur absent',
    'Paiement contesté',
    'Autre',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_descriptionController.text.trim().length < 10) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Décrivez le problème en au moins 10 caractères.'),
          ),
        );
      return;
    }
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() => _submitting = false);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF08713B),
          size: 48,
        ),
        title: const Text('Signalement envoyé'),
        content: const Text(
          'Notre équipe va examiner votre demande et vous tenir informé.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(this.context).pushReplacementNamed(
                BuyerIssueDetailPage.routeName,
                arguments: const BuyerIssueDetailArguments(),
              );
            },
            child: const Text('Terminer'),
          ),
        ],
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
            SliverToBoxAdapter(
              child: _ReportHeader(reference: widget.arguments.reference),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(28, 30, 28, 28 + bottomInset),
              sliver: SliverList.list(
                children: [
                  const Text(
                    'Motif du signalement',
                    style: TextStyle(
                      color: Color(0xFF344054),
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ...List.generate(
                    _reasons.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: _ReasonTile(
                        label: _reasons[index],
                        selected: _selectedReason == index,
                        onTap: () => setState(() => _selectedReason = index),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: Color(0xFF344054),
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _descriptionController,
                    minLines: 5,
                    maxLines: 8,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Décrivez précisément le problème…',
                      hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFD8E0EA),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFFD8E0EA),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _evidenceCount++),
                    icon: const Icon(Icons.add_rounded, size: 26),
                    label: Text(
                      _evidenceCount == 0
                          ? 'Ajouter des photos ou preuves'
                          : '$_evidenceCount preuve${_evidenceCount > 1 ? 's' : ''} ajoutée${_evidenceCount > 1 ? 's' : ''}',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(60),
                      foregroundColor: const Color(0xFF263247),
                      backgroundColor: const Color(0xFFF7F9FB),
                      side: const BorderSide(color: Color(0xFFE6EBF1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(58),
                      backgroundColor: const Color(0xFFF04444),
                      disabledBackgroundColor:
                          const Color(0xFFF04444).withValues(alpha: 0.55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.white,
                            ),
                          )
                        : const Text(
                            'Envoyer le signalement',
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
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({required this.reference});

  final String reference;

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
                  'Signaler un problème',
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
                  reference,
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

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFF04444) : const Color(0xFFCBD5E1);
    return Material(
      color: selected ? const Color(0xFFFFEAEA) : AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color, width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: selected
                    ? const DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF04444),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: const Color(0xFF344054),
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
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
