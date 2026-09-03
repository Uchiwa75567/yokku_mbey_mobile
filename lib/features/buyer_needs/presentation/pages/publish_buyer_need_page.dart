import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import 'buyer_needs_page.dart';
import '../../../buyer_support/presentation/pages/buyer_action_success_page.dart';

class PublishBuyerNeedArguments {
  const PublishBuyerNeedArguments({
    this.editing = false,
    this.product = '',
    this.quantity = '',
    this.region = '',
    this.budget = '',
    this.date = '',
    this.details = '',
  });

  final bool editing;
  final String product;
  final String quantity;
  final String region;
  final String budget;
  final String date;
  final String details;
}

class PublishBuyerNeedPage extends StatefulWidget {
  const PublishBuyerNeedPage({
    super.key,
    this.arguments = const PublishBuyerNeedArguments(),
  });

  static const String routeName = '/publish-buyer-need';

  final PublishBuyerNeedArguments arguments;

  static Widget fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return PublishBuyerNeedPage(
      arguments: arguments is PublishBuyerNeedArguments
          ? arguments
          : const PublishBuyerNeedArguments(),
    );
  }

  @override
  State<PublishBuyerNeedPage> createState() => _PublishBuyerNeedPageState();
}

class _PublishBuyerNeedPageState extends State<PublishBuyerNeedPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _productController;
  late final TextEditingController _quantityController;
  late final TextEditingController _regionController;
  late final TextEditingController _budgetController;
  late final TextEditingController _dateController;
  late final TextEditingController _detailsController;

  String _unit = 'Kilogramme';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.arguments;
    _productController = TextEditingController(text: initial.product);
    _quantityController = TextEditingController(text: initial.quantity);
    _regionController = TextEditingController(text: initial.region);
    _budgetController = TextEditingController(text: initial.budget);
    _dateController = TextEditingController(text: initial.date);
    _detailsController = TextEditingController(text: initial.details);
  }

  @override
  void dispose() {
    _productController.dispose();
    _quantityController.dispose();
    _regionController.dispose();
    _budgetController.dispose();
    _dateController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      helpText: 'Date souhaitée',
      cancelText: 'Annuler',
      confirmText: 'Choisir',
    );
    if (selected == null || !mounted) return;
    _dateController.text = '${selected.day.toString().padLeft(2, '0')}/'
        '${selected.month.toString().padLeft(2, '0')}/'
        '${selected.year}';
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => _submitting = false);

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => BuyerActionSuccessPage(
          arguments: BuyerActionSuccessArguments(
            title: widget.arguments.editing
                ? 'Demande modifiée'
                : 'Demande publiée',
            message: widget.arguments.editing
                ? 'Les producteurs verront désormais les nouvelles informations.'
                : 'Votre demande de ${_productController.text.trim()} est '
                    'maintenant visible par les producteurs.',
            buttonLabel: 'Voir mes demandes',
            destinationRoute: BuyerNeedsPage.routeName,
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
            SliverToBoxAdapter(
              child: _NeedHeader(
                editing: widget.arguments.editing,
                product: _productController.text,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(24, 18, 24, 28 + bottomInset),
              sliver: SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Décrivez votre besoin',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _FormLabel(
                        label: 'Produit recherché',
                        required: true,
                      ),
                      const SizedBox(height: 9),
                      _NeedTextField(
                        controller: _productController,
                        hintText: 'Ex. Tomate fraîche',
                        textInputAction: TextInputAction.next,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _FormLabel(
                                  label: 'Quantité',
                                  required: true,
                                ),
                                const SizedBox(height: 9),
                                _NeedTextField(
                                  controller: _quantityController,
                                  hintText: '1 000',
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: _requiredValidator,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _FormLabel(
                                  label: 'Unité',
                                  required: true,
                                ),
                                const SizedBox(height: 9),
                                DropdownButtonFormField<String>(
                                  initialValue: _unit,
                                  isExpanded: true,
                                  decoration: _fieldDecoration('Unité'),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Kilogramme',
                                      child: Text('Kilogramme'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Tonne',
                                      child: Text('Tonne'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Sac',
                                      child: Text('Sac'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Caisse',
                                      child: Text('Caisse'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _unit = value);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const _FormLabel(label: 'Région souhaitée'),
                      const SizedBox(height: 9),
                      _NeedTextField(
                        controller: _regionController,
                        hintText: 'Dakar ou Thiès',
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 24),
                      const _FormLabel(label: 'Budget maximum'),
                      const SizedBox(height: 9),
                      _NeedTextField(
                        controller: _budgetController,
                        hintText: '450 FCFA/kg',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 24),
                      const _FormLabel(label: 'Date souhaitée'),
                      const SizedBox(height: 9),
                      _NeedTextField(
                        controller: _dateController,
                        hintText: '20/07/2026',
                        readOnly: true,
                        onTap: _selectDate,
                        suffixIcon: const Icon(
                          Icons.calendar_today_outlined,
                          color: Color(0xFF75849A),
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _FormLabel(label: 'Précisions'),
                      const SizedBox(height: 9),
                      _NeedTextField(
                        controller: _detailsController,
                        hintText: 'Qualité, variété, livraison...',
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _submitting ? null : _submit,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(58),
                          backgroundColor: const Color(0xFF076735),
                          disabledBackgroundColor: const Color(0xFFA8CDB5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        child: _submitting
                            ? const SizedBox.square(
                                dimension: 23,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                widget.arguments.editing
                                    ? 'Enregistrer les modifications'
                                    : 'Publier la demande',
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

class _NeedHeader extends StatelessWidget {
  const _NeedHeader({
    required this.editing,
    required this.product,
  });

  final bool editing;
  final String product;

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
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              fixedSize: const Size(48, 48),
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
                  editing ? 'Modifier la demande' : 'Publier une demande',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  editing ? product : 'Ce produit n’est pas disponible ?',
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

class _FormLabel extends StatelessWidget {
  const _FormLabel({required this.label, this.required = false});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: label),
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
        ],
      ),
      style: const TextStyle(
        color: Color(0xFF48566C),
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _NeedTextField extends StatelessWidget {
  const _NeedTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16),
      decoration: _fieldDecoration(hintText).copyWith(suffixIcon: suffixIcon),
    );
  }
}

InputDecoration _fieldDecoration(String hintText) {
  const borderColor = Color(0xFFD9DEE6);
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: Color(0xFF9AAAC1), fontSize: 16),
    filled: true,
    fillColor: AppColors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: Color(0xFF087C2E), width: 1.8),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: Color(0xFFEF4444)),
    ),
  );
}

String? _requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Ce champ est obligatoire';
  }
  return null;
}
