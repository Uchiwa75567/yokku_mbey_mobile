import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/external_contact_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/farmer_glass_surface.dart';

class FarmerProductResponseData {
  const FarmerProductResponseData({
    required this.productName,
    required this.buyerName,
    required this.requestedQuantity,
    required this.targetPrice,
    this.buyerPhone = '+221 77 450 20 20',
  });

  final String productName;
  final String buyerName;
  final String requestedQuantity;
  final String targetPrice;
  final String buyerPhone;
}

class FarmerProductResponsePage extends StatefulWidget {
  const FarmerProductResponsePage({required this.data, super.key});

  static const routeName = '/farmer-product-response';

  final FarmerProductResponseData data;

  static FarmerProductResponsePage fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return FarmerProductResponsePage(
      data: arguments is FarmerProductResponseData
          ? arguments
          : const FarmerProductResponseData(
              productName: 'Tomate fraîche',
              buyerName: 'Marché Central Dakar',
              requestedQuantity: '500 kg',
              targetPrice: '400 FCFA/kg',
            ),
    );
  }

  @override
  State<FarmerProductResponsePage> createState() =>
      _FarmerProductResponsePageState();
}

class _FarmerProductResponsePageState extends State<FarmerProductResponsePage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '500');
  final _priceController = TextEditingController(text: '400');
  final _availabilityController = TextEditingController(text: '15/08/2026');
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _availabilityController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Color(0xFF087C3A),
          size: 46,
        ),
        title: const Text('Proposition envoyée'),
        content: Text(
          '${widget.data.buyerName} pourra consulter votre quantité, votre prix et votre disponibilité.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF18241D),
        appBar: AppBar(
          backgroundColor: const Color(0xCC131513),
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: const Text('Répondre à la demande'),
        ),
        body: Stack(
          children: [
            const Positioned.fill(
              child: FarmerGlassBackground(overlayOpacity: 0.46),
            ),
            Positioned.fill(
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: FarmerGlassSurface(
                    color: const Color(0xE6FFFFFF),
                    blurSigma: 20,
                    borderRadius: BorderRadius.circular(28),
                    borderColor: const Color(0x66FFFFFF),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          _RequestSummary(data: data),
                          const SizedBox(height: 24),
                          _Field(
                            label: 'Quantité proposée *',
                            controller: _quantityController,
                            suffix: 'kg',
                            keyboardType: TextInputType.number,
                          ),
                          _Field(
                            label: 'Prix unitaire *',
                            controller: _priceController,
                            suffix: 'FCFA/kg',
                            keyboardType: TextInputType.number,
                          ),
                          _Field(
                            label: 'Date de disponibilité *',
                            controller: _availabilityController,
                          ),
                          _Field(
                            label: 'Message à l’acheteur',
                            controller: _messageController,
                            maxLines: 4,
                            required: false,
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () =>
                                ExternalContactService.showContactOptions(
                              context,
                              phoneNumber: data.buyerPhone,
                              contactName: data.buyerName,
                              message:
                                  'Bonjour, je souhaite répondre à votre demande de ${data.productName} vue sur YOKKU MBEY.',
                            ),
                            icon: const Icon(Icons.call_outlined),
                            label: const Text('Appeler ou WhatsApp l’acheteur'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(54),
                              foregroundColor: const Color(0xFF087C3A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _submit,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              backgroundColor: const Color(0xFF087C3A),
                            ),
                            child: const Text('Envoyer ma proposition'),
                          ),
                        ],
                      ),
                    ),
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

class SeedSearchPage extends StatefulWidget {
  const SeedSearchPage({super.key});

  static const routeName = '/seed-search';

  @override
  State<SeedSearchPage> createState() => _SeedSearchPageState();
}

class _SeedSearchPageState extends State<SeedSearchPage> {
  String _query = '';

  static const _seeds = [
    (
      name: 'Semences de tomate Roma',
      supplier: 'Agri Semences Thiès',
      region: 'Thiès',
      price: '12 500 FCFA / sachet',
      phone: '+221 77 310 40 50',
    ),
    (
      name: 'Semences d’oignon Violet de Galmi',
      supplier: 'Comptoir agricole Kaolack',
      region: 'Kaolack',
      price: '9 000 FCFA / boîte',
      phone: '+221 76 220 10 30',
    ),
    (
      name: 'Semences de maïs certifiées',
      supplier: 'Coopérative du Saloum',
      region: 'Fatick',
      price: '18 000 FCFA / sac',
      phone: '+221 78 540 60 70',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final results = _seeds
        .where(
          (seed) => '${seed.name} ${seed.supplier} ${seed.region}'
              .toLowerCase()
              .contains(_query.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF18241D),
      appBar: AppBar(
        backgroundColor: const Color(0xCC131513),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Rechercher des semences'),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: FarmerGlassBackground(overlayOpacity: 0.46),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FarmerGlassSurface(
                color: const Color(0xE6FFFFFF),
                blurSigma: 20,
                borderRadius: BorderRadius.circular(28),
                borderColor: const Color(0x66FFFFFF),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    TextField(
                      onChanged: (value) =>
                          setState(() => _query = value.trim()),
                      decoration: InputDecoration(
                        hintText: 'Tomate, oignon, maïs…',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${results.length} fournisseur${results.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final seed in results)
                      Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: Padding(
                          padding: const EdgeInsets.all(17),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Color(0xFFE7F8EE),
                                    child: Icon(Icons.spa,
                                        color: Color(0xFF087C3A)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      seed.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text('${seed.supplier} • ${seed.region}'),
                              const SizedBox(height: 5),
                              Text(
                                seed.price,
                                style: const TextStyle(
                                  color: Color(0xFF087C3A),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: () =>
                                    ExternalContactService.showContactOptions(
                                  context,
                                  phoneNumber: seed.phone,
                                  contactName: seed.supplier,
                                  message:
                                      'Bonjour, je souhaite obtenir des informations sur ${seed.name} via YOKKU MBEY.',
                                ),
                                icon: const Icon(Icons.call_outlined),
                                label: const Text('Appeler ou WhatsApp'),
                              ),
                            ],
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
    );
  }
}

class _RequestSummary extends StatelessWidget {
  const _RequestSummary({required this.data});

  final FarmerProductResponseData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.productName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 7),
          Text(data.buyerName),
          Text('${data.requestedQuantity} • Cible ${data.targetPrice}'),
          const SizedBox(height: 5),
          Text(
            data.buyerPhone,
            style: const TextStyle(
              color: Color(0xFF087C3A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.suffix,
    this.keyboardType,
    this.maxLines = 1,
    this.required = true,
  });

  final String label;
  final TextEditingController controller;
  final String? suffix;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: required
            ? (value) =>
                value == null || value.trim().isEmpty ? 'Champ requis' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
