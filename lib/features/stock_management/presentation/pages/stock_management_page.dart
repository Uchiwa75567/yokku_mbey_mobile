import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/farmer_glass_surface.dart';

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
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: SizedBox(
                    width: scaledWidth,
                    height: scaledHeight,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: designWidth,
                        height: designHeight,
                        child: _StockManagementCanvas(
                          stock: widget.stock,
                          remainingQuantity: _remainingQuantity,
                          quantityController: _quantityController,
                          onBack: () => Navigator.of(context).maybePop(),
                          onUpdate: _updateStock,
                          onMarkAsSoldOut: _markAsSoldOut,
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

class _StockManagementCanvas extends StatelessWidget {
  const _StockManagementCanvas({
    required this.stock,
    required this.remainingQuantity,
    required this.quantityController,
    required this.onBack,
    required this.onUpdate,
    required this.onMarkAsSoldOut,
  });

  final StockManagementData stock;
  final int remainingQuantity;
  final TextEditingController quantityController;
  final VoidCallback onBack;
  final VoidCallback onUpdate;
  final VoidCallback onMarkAsSoldOut;

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
          right: 26,
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
                      'Gestion du stock',
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
                      stock.productName,
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
          left: 36,
          right: 46,
          top: 186,
          child: _CurrentStockCard(quantity: remainingQuantity),
        ),
        const Positioned(
          left: 38,
          top: 323,
          child: Text(
            'Résumé',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        Positioned(
          left: 38,
          right: 44,
          top: 362,
          child: Column(
            children: [
              _SummaryRow(
                label: 'Quantité initiale',
                value: '${_formatQuantity(stock.initialQuantity)} kg',
              ),
              const SizedBox(height: 9),
              _SummaryRow(
                label: 'Quantité réservée',
                value: '${_formatQuantity(stock.reservedQuantity)} kg',
              ),
              const SizedBox(height: 9),
              _SummaryRow(
                label: 'Quantité vendue',
                value: '${_formatQuantity(stock.soldQuantity)} kg',
              ),
              const SizedBox(height: 9),
              _SummaryRow(
                label: 'Quantité restante',
                value: '${_formatQuantity(remainingQuantity)} kg',
              ),
            ],
          ),
        ),
        const Positioned(
          left: 36,
          top: 640,
          child: Text(
            'Mettre à jour',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        const Positioned(
          left: 36,
          top: 680,
          child: Text(
            'Nouvelle quantité restante',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        Positioned(
          left: 36,
          right: 46,
          top: 712,
          child: SizedBox(
            height: 58,
            child: TextField(
              key: const ValueKey('stock-quantity-field'),
              controller: quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                color: Color(0xFF8FA0BA),
                fontSize: 17,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
              decoration: InputDecoration(
                suffixText: 'kg',
                suffixStyle: const TextStyle(
                  color: Color(0xFF8FA0BA),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
              ),
            ),
          ),
        ),
        Positioned(
          left: 38,
          right: 44,
          bottom: 43,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 58,
                  child: FilledButton(
                    key: const ValueKey('update-stock-button'),
                    onPressed: onUpdate,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF076B3B),
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    child: const Text('Mettre à jour'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 58,
                  child: OutlinedButton(
                    key: const ValueKey('mark-sold-out-button'),
                    onPressed: onMarkAsSoldOut,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: const Color(0xFFF0444A),
                      side: const BorderSide(
                        color: Color(0xFFFF6267),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    child: const Text(
                      'Marquer épuisée',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
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

class _CurrentStockCard extends StatelessWidget {
  const _CurrentStockCard({required this.quantity});

  final int quantity;

  @override
  Widget build(BuildContext context) {
    final isAvailable = quantity > 0;
    return Container(
      height: 121,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE8EDF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stock actuel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF95A5BF),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 45,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_formatQuantity(quantity)} kg',
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 37,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isAvailable
                  ? const Color(0xFFE7F4EA)
                  : const Color(0xFFFFE9EB),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              isAvailable ? 'Disponible' : 'Épuisée',
              style: TextStyle(
                color: isAvailable
                    ? const Color(0xFF285B35)
                    : const Color(0xFFD9323A),
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 57,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F2F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 7,
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
                color: Color(0xFF9AAAC2),
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
