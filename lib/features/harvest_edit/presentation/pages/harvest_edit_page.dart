import '../../../../core/widgets/journey_scaffold.dart';
import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) => Form(
      key: _formKey,
      child: JourneyScaffold(
          title: 'Modifier la récolte',
          subtitle: widget.harvest.name,
          children: [
            const JourneyHeading('Informations de vente'),
            TextFormField(
                key: const ValueKey('harvest-price-field'),
                controller: _priceController,
                validator: _validatePositiveValue,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Prix de vente')),
            TextFormField(
                key: const ValueKey('harvest-quantity-field'),
                controller: _quantityController,
                validator: _validatePositiveValue,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Quantité restante')),
            TextFormField(
                key: const ValueKey('harvest-minimum-field'),
                controller: _minimumOrderController,
                validator: _validatePositiveValue,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Commande minimum')),
            ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_available_outlined),
                title: const Text('Disponibilité'),
                subtitle: Text(widget.harvest.availability)),
            const JourneyNotice(
                'Aperçu local : les modifications ne sont pas transmises à un serveur.'),
            JourneyButton(
                label: 'Enregistrer les modifications',
                icon: Icons.check,
                onPressed: () async => _saveChanges()),
          ]));
}
