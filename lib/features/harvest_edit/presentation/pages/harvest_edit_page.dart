import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/farmer_glass_surface.dart';

class HarvestEditData {
  const HarvestEditData({
    required this.name,
    required this.unitPrice,
    required this.remainingQuantity,
    required this.minimumOrder,
    required this.availability,
    required this.reservationCount,
  });

  final String name;
  final int unitPrice;
  final int remainingQuantity;
  final int minimumOrder;
  final String availability;
  final int reservationCount;
}

class HarvestEditPage extends StatefulWidget {
  const HarvestEditPage({
    super.key,
    required this.harvest,
  });

  static const String routeName = '/harvest-edit';

  static const HarvestEditData defaultHarvest = HarvestEditData(
    name: 'Tomate fraîche',
    unitPrice: 400,
    remainingQuantity: 300,
    minimumOrder: 50,
    availability: 'Disponible maintenant',
    reservationCount: 18,
  );

  final HarvestEditData harvest;

  static Widget fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return HarvestEditPage(
      harvest: arguments is HarvestEditData ? arguments : defaultHarvest,
    );
  }

  @override
  State<HarvestEditPage> createState() => _HarvestEditPageState();
}

class _HarvestEditPageState extends State<HarvestEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _minimumOrderController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: '${widget.harvest.unitPrice} FCFA/kg',
    );
    _quantityController = TextEditingController(
      text: '${widget.harvest.remainingQuantity} kg',
    );
    _minimumOrderController = TextEditingController(
      text: '${widget.harvest.minimumOrder} kg',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    _minimumOrderController.dispose();
    super.dispose();
  }

  String? _validatePositiveValue(String? value) {
    final digits = value?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    final parsedValue = int.tryParse(digits);
    if (parsedValue == null || parsedValue <= 0) {
      return 'Saisissez une valeur valide';
    }
    return null;
  }

  void _saveChanges() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Modifications enregistrées'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
                        child: Form(
                          key: _formKey,
                          child: _HarvestEditCanvas(
                            harvest: widget.harvest,
                            priceController: _priceController,
                            quantityController: _quantityController,
                            minimumOrderController: _minimumOrderController,
                            validator: _validatePositiveValue,
                            onBack: () => Navigator.of(context).maybePop(),
                            onSave: _saveChanges,
                          ),
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

class _HarvestEditCanvas extends StatelessWidget {
  const _HarvestEditCanvas({
    required this.harvest,
    required this.priceController,
    required this.quantityController,
    required this.minimumOrderController,
    required this.validator,
    required this.onBack,
    required this.onSave,
  });

  final HarvestEditData harvest;
  final TextEditingController priceController;
  final TextEditingController quantityController;
  final TextEditingController minimumOrderController;
  final FormFieldValidator<String> validator;
  final VoidCallback onBack;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: FarmerGlassBackground(overlayOpacity: 0.46),
        ),
        const Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 159,
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
          left: 17,
          right: 28,
          top: 75,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BackButton(onPressed: onBack),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Modifier la récolte',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      harvest.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 35,
          right: 47,
          top: 204,
          child: _LockedInformationBanner(
            reservationCount: harvest.reservationCount,
          ),
        ),
        Positioned(
          left: 35,
          right: 47,
          top: 311,
          child: Column(
            children: [
              _EditField(
                label: 'Nom du produit',
                initialValue: harvest.name,
                readOnly: true,
              ),
              const SizedBox(height: 19),
              _EditField(
                key: const ValueKey('harvest-price-field'),
                label: 'Prix par unité',
                controller: priceController,
                keyboardType: TextInputType.number,
                validator: validator,
              ),
              const SizedBox(height: 19),
              _EditField(
                key: const ValueKey('harvest-quantity-field'),
                label: 'Quantité restante',
                controller: quantityController,
                keyboardType: TextInputType.number,
                validator: validator,
              ),
              const SizedBox(height: 19),
              _EditField(
                key: const ValueKey('harvest-minimum-field'),
                label: 'Commande minimale',
                controller: minimumOrderController,
                keyboardType: TextInputType.number,
                validator: validator,
              ),
              const SizedBox(height: 19),
              _EditField(
                label: 'Disponibilité',
                initialValue: harvest.availability,
                readOnly: true,
              ),
            ],
          ),
        ),
        Positioned(
          left: 37,
          right: 53,
          bottom: 38,
          child: SizedBox(
            height: 56,
            child: FilledButton(
              onPressed: onSave,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF076B2C),
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              child: const Text('Enregistrer les modifications'),
            ),
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 36,
      child: Material(
        color: AppColors.white.withValues(alpha: 0.3),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: const Icon(
            Icons.chevron_left,
            color: AppColors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _LockedInformationBanner extends StatelessWidget {
  const _LockedInformationBanner({required this.reservationCount});

  final int reservationCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 81,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF7817)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$reservationCount réservations déjà reçues',
            style: const TextStyle(
              color: Color(0xFFFF6B0B),
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Certaines informations sont maintenant verrouillées.',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(0xFF647188),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.readOnly = false,
    this.keyboardType,
    this.validator,
  }) : assert(controller == null || initialValue == null);

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final bool readOnly;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            readOnly: readOnly,
            canRequestFocus: !readOnly,
            keyboardType: keyboardType,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(
              color: Color(0xFF8FA0BA),
              fontSize: 17,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFDCE3EC)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF087C3A),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE43E45)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE43E45)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
