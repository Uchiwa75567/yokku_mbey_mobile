import '../../../../core/widgets/journey_scaffold.dart';
import 'package:flutter/material.dart';

String _formatQuantity(int quantity) {
  return quantity.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ' ',
      );
}

class StockManagementData {
  const StockManagementData({
    required this.productName,
    required this.initialQuantity,
    required this.reservedQuantity,
    required this.soldQuantity,
    required this.remainingQuantity,
  });

  final String productName;
  final int initialQuantity;
  final int reservedQuantity;
  final int soldQuantity;
  final int remainingQuantity;
}

class StockManagementPage extends StatefulWidget {
  const StockManagementPage({
    super.key,
    required this.stock,
  });

  static const String routeName = '/stock-management';

  static const StockManagementData defaultStock = StockManagementData(
    productName: 'Tomate fraîche',
    initialQuantity: 1000,
    reservedQuantity: 300,
    soldQuantity: 400,
    remainingQuantity: 300,
  );

  final StockManagementData stock;

  static Widget fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return StockManagementPage(
      stock: arguments is StockManagementData ? arguments : defaultStock,
    );
  }

  @override
  State<StockManagementPage> createState() => _StockManagementPageState();
}

class _StockManagementPageState extends State<StockManagementPage> {
  late final TextEditingController _quantityController;
  late int _remainingQuantity;

  @override
  void initState() {
    super.initState();
    _remainingQuantity = widget.stock.remainingQuantity;
    _quantityController = TextEditingController(
      text: widget.stock.remainingQuantity.toString(),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _updateStock() {
    FocusScope.of(context).unfocus();
    final quantity = int.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity < 0) {
      _showMessage('Saisissez une quantité valide');
      return;
    }

    setState(() => _remainingQuantity = quantity);
    _showMessage('Stock mis à jour');
  }

  void _markAsSoldOut() {
    FocusScope.of(context).unfocus();
    setState(() {
      _remainingQuantity = 0;
      _quantityController.text = '0';
    });
    _showMessage('La récolte est maintenant épuisée');
  }

  @override
  Widget build(BuildContext context) => JourneyScaffold(
          title: 'Gestion du stock',
          subtitle: widget.stock.productName,
          children: [
            const JourneyHeading('Stock disponible'),
            Text(_remainingQuantity == 0 ? 'Épuisée' : 'Disponible',
                style: const TextStyle(color: journeyGreen)),
            Text('${_formatQuantity(_remainingQuantity)} kg',
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: journeyGreen)),
            const Divider(),
            for (final item in <(String, int)>[
              ('Quantité initiale', widget.stock.initialQuantity),
              ('Quantité réservée', widget.stock.reservedQuantity),
              ('Quantité vendue', widget.stock.soldQuantity),
            ])
              Row(children: [
                Expanded(child: Text(item.$1)),
                Text('${_formatQuantity(item.$2)} kg',
                    style: const TextStyle(fontWeight: FontWeight.w600))
              ]),
            const Divider(),
            const JourneyHeading('Mettre à jour le stock'),
            TextField(
                key: const ValueKey('stock-quantity-field'),
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Nouvelle quantité disponible',
                    suffixText: 'kg')),
            JourneyButton(
                key: const ValueKey('update-stock-button'),
                label: 'Mettre à jour',
                icon: Icons.check,
                onPressed: () async => _updateStock()),
            OutlinedButton.icon(
                key: const ValueKey('mark-sold-out-button'),
                onPressed: _markAsSoldOut,
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Marquer comme épuisée')),
            const JourneyNotice(
                'Aperçu local. Le stock affiché ici n’est pas synchronisé avec les commandes.'),
          ]);
}
