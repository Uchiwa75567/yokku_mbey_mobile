import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/buyer_address_data.dart';

class BuyerAddressFormPage extends StatefulWidget {
  const BuyerAddressFormPage({super.key, this.initialAddress});

  static const String routeName = '/buyer-address-form';

  final BuyerAddressData? initialAddress;

  static Widget fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return BuyerAddressFormPage(
      initialAddress: arguments is BuyerAddressData ? arguments : null,
    );
  }

  @override
  State<BuyerAddressFormPage> createState() => _BuyerAddressFormPageState();
}

class _BuyerAddressFormPageState extends State<BuyerAddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _regionController;
  late final TextEditingController _cityController;
  late final TextEditingController _neighborhoodController;
  late final TextEditingController _detailsController;
  late final TextEditingController _phoneController;
  late bool _isPrimary;

  bool get _editing => widget.initialAddress != null;

  @override
  void initState() {
    super.initState();
    final address = widget.initialAddress;
    _nameController = TextEditingController(text: address?.name ?? '');
    _regionController = TextEditingController(text: address?.region ?? '');
    _cityController = TextEditingController(text: address?.city ?? '');
    _neighborhoodController = TextEditingController(
      text: address?.neighborhood ?? '',
    );
    _detailsController = TextEditingController(text: address?.details ?? '');
    _phoneController = TextEditingController(text: address?.phone ?? '');
    _isPrimary = address?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regionController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _detailsController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final previous = widget.initialAddress;
    Navigator.of(context).pop(
      BuyerAddressData(
        name: _nameController.text.trim(),
        region: _regionController.text.trim(),
        city: _cityController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
        details: _detailsController.text.trim(),
        phone: _phoneController.text.trim(),
        icon: previous?.icon ?? Icons.location_on_outlined,
        accentColor: previous?.accentColor ?? const Color(0xFF087C2E),
        backgroundColor: previous?.backgroundColor ?? const Color(0xFFE5F3EA),
        isPrimary: _isPrimary,
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
              child: _FormHeader(editing: _editing),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(40, 22, 40, 28 + bottomInset),
              sliver: SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AddressField(
                        label: "Nom de l'adresse",
                        hint: 'Ex. Boutique principale',
                        controller: _nameController,
                      ),
                      _AddressField(
                        label: 'Région',
                        hint: 'Dakar',
                        controller: _regionController,
                      ),
                      _AddressField(
                        label: 'Département ou ville',
                        hint: 'Dakar',
                        controller: _cityController,
                      ),
                      _AddressField(
                        label: 'Commune / quartier',
                        hint: 'Médina',
                        controller: _neighborhoodController,
                      ),
                      _AddressField(
                        label: 'Adresse détaillée',
                        hint: 'Rue 22 x 17',
                        controller: _detailsController,
                      ),
                      _AddressField(
                        label: 'Téléphone',
                        hint: '77 000 00 00',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F9FB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFDDE3EA)),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Définir comme adresse principale',
                                style: TextStyle(
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Switch(
                              value: _isPrimary,
                              activeThumbColor: AppColors.white,
                              activeTrackColor: const Color(0xFF06723B),
                              onChanged: (value) =>
                                  setState(() => _isPrimary = value),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton(
                        onPressed: _save,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(58),
                          backgroundColor: const Color(0xFF076735),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          _editing
                              ? "Enregistrer les modifications"
                              : "Enregistrer l'adresse",
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

class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.editing});

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
                  editing ? "Modifier l'adresse" : 'Ajouter une adresse',
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
                  editing
                      ? 'Mettez à jour le lieu de réception'
                      : 'Nouvelle adresse de livraison',
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

class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: TextInputAction.next,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Ce champ est obligatoire'
                : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF697386)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: Color(0xFFDDE3EA)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: Color(0xFFDDE3EA)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(
                  color: Color(0xFF087C2E),
                  width: 1.7,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
