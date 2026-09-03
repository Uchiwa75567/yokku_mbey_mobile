import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import 'buyer_favorites_page.dart';

class BuyerCreateAlertArguments {
  const BuyerCreateAlertArguments({
    this.product = 'Tomate fraîche',
    this.region = 'Dakar',
    this.editing = false,
    this.targetPrice = '400',
    this.minimumQuantity = '100',
  });

  final String product;
  final String region;
  final bool editing;
  final String targetPrice;
  final String minimumQuantity;
}

class BuyerCreateAlertPage extends StatefulWidget {
  const BuyerCreateAlertPage({super.key, required this.arguments});

  static const String routeName = '/buyer-create-alert';

  final BuyerCreateAlertArguments arguments;

  static Widget fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return BuyerCreateAlertPage(
      arguments: arguments is BuyerCreateAlertArguments
          ? arguments
          : const BuyerCreateAlertArguments(),
    );
  }

  @override
  State<BuyerCreateAlertPage> createState() => _BuyerCreateAlertPageState();
}

class _BuyerCreateAlertPageState extends State<BuyerCreateAlertPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _productController;
  late final TextEditingController _regionController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  bool _availableNow = true;
  String _frequency = 'Immédiatement';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _productController = TextEditingController(text: widget.arguments.product);
    _regionController = TextEditingController(text: widget.arguments.region);
    _priceController =
        TextEditingController(text: widget.arguments.targetPrice);
    _quantityController =
        TextEditingController(text: widget.arguments.minimumQuantity);
  }

  @override
  void dispose() {
    _productController.dispose();
    _regionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() => _submitting = false);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.notifications_active_rounded,
          color: Color(0xFF08713B),
          size: 48,
        ),
        title: Text(
          widget.arguments.editing ? 'Alerte modifiée' : 'Alerte créée',
        ),
        content: Text(
          'Vous serez averti $_frequency lorsque ${_productController.text} '
          'sera disponible au prix souhaité.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushReplacementNamed(
                BuyerFavoritesPage.routeName,
              );
            },
            child: const Text('Voir mes alertes'),
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
              child: _AlertHeader(editing: widget.arguments.editing),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(32, 24, 32, 32 + bottomInset),
              sliver: SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AlertField(
                        label: 'Produit',
                        controller: _productController,
                        hintText: 'Tomate fraîche',
                      ),
                      _AlertField(
                        label: 'Région',
                        controller: _regionController,
                        hintText: 'Dakar',
                      ),
                      _AlertField(
                        label: 'Prix maximum',
                        controller: _priceController,
                        hintText: '400 FCFA/kg',
                        keyboardType: TextInputType.number,
                        suffixText: 'FCFA/kg',
                      ),
                      _AlertField(
                        label: 'Quantité minimale',
                        controller: _quantityController,
                        hintText: '100 kg',
                        keyboardType: TextInputType.number,
                        suffixText: 'kg',
                      ),
                      const Text(
                        'Disponibilité',
                        style: _labelStyle,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _AvailabilityButton(
                              label: 'Disponible maintenant',
                              selected: _availableNow,
                              onTap: () => setState(() => _availableNow = true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _AvailabilityButton(
                              label: 'Disponible prochainement',
                              selected: !_availableNow,
                              onTap: () =>
                                  setState(() => _availableNow = false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Fréquence des notifications',
                        style: _labelStyle,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: _frequency,
                        isExpanded: true,
                        decoration: _decoration('Immédiatement'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Immédiatement',
                            child: Text('Immédiatement'),
                          ),
                          DropdownMenuItem(
                            value: 'Une fois par jour',
                            child: Text('Une fois par jour'),
                          ),
                          DropdownMenuItem(
                            value: 'Une fois par semaine',
                            child: Text('Une fois par semaine'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _frequency = value);
                          }
                        },
                      ),
                      const SizedBox(height: 56),
                      FilledButton(
                        onPressed: _submitting ? null : _submit,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(58),
                          backgroundColor: const Color(0xFF076735),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _submitting
                            ? const SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                widget.arguments.editing
                                    ? 'Enregistrer les modifications'
                                    : "Créer l’alerte",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertHeader extends StatelessWidget {
  const _AlertHeader({required this.editing});
  final bool editing;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editing ? 'Modifier l’alerte' : 'Créer une alerte',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Recevez une notification au bon moment',
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

class _AlertField extends StatelessWidget {
  const _AlertField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.suffixText,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final String? suffixText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _labelStyle),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Ce champ est obligatoire'
                : null,
            decoration: _decoration(hintText).copyWith(suffixText: suffixText),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityButton extends StatelessWidget {
  const _AvailabilityButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        backgroundColor: selected ? const Color(0xFFF0F8F3) : AppColors.white,
        foregroundColor:
            selected ? const Color(0xFF076735) : const Color(0xFF94A3B8),
        side: BorderSide(
          color: selected ? const Color(0xFF076735) : const Color(0xFFDDE3EA),
        ),
        shape: const StadiumBorder(),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

const _labelStyle = TextStyle(
  color: Color(0xFF344054),
  fontSize: 16,
  fontWeight: FontWeight.w800,
);

InputDecoration _decoration(String hintText) {
  const border = Color(0xFFD9E0E8);
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: Color(0xFF087C2E), width: 1.8),
    ),
  );
}
