import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/buyer_address_data.dart';
import 'buyer_address_form_page.dart';

class BuyerDeliveryAddressesPage extends StatefulWidget {
  const BuyerDeliveryAddressesPage({super.key});

  static const String routeName = '/buyer-delivery-addresses';

  @override
  State<BuyerDeliveryAddressesPage> createState() =>
      _BuyerDeliveryAddressesPageState();
}

class _BuyerDeliveryAddressesPageState
    extends State<BuyerDeliveryAddressesPage> {
  final List<BuyerAddressData> _addresses = List.of(_initialAddresses);

  Future<void> _openForm({int? index}) async {
    final address = index == null ? null : _addresses[index];
    final result = await Navigator.of(context).pushNamed(
      BuyerAddressFormPage.routeName,
      arguments: address,
    );
    if (result is! BuyerAddressData || !mounted) return;

    setState(() {
      if (result.isPrimary) {
        for (var i = 0; i < _addresses.length; i++) {
          _addresses[i] = _addresses[i].copyWith(isPrimary: false);
        }
      }
      if (index == null) {
        _addresses.add(result);
      } else {
        _addresses[index] = result;
      }
    });
  }

  Future<void> _deleteAddress(int index) async {
    final address = _addresses[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer l'adresse ?"),
        content: Text(
          '${address.name} sera définitivement retirée de vos adresses.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Conserver'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _addresses.removeAt(index));
    }
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
          slivers: [
            const SliverToBoxAdapter(child: _AddressHeader()),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(44, 34, 44, 30 + bottomInset),
              sliver: SliverList.list(
                children: [
                  FilledButton.icon(
                    onPressed: _openForm,
                    icon: const Icon(Icons.add_rounded, size: 25),
                    label: const Text(
                      'Ajouter une adresse',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(60),
                      backgroundColor: const Color(0xFF07572F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (_addresses.isEmpty)
                    const _EmptyAddresses()
                  else
                    for (var index = 0; index < _addresses.length; index++) ...[
                      _AddressCard(
                        address: _addresses[index],
                        onEdit: () => _openForm(index: index),
                        onDelete: () => _deleteAddress(index),
                      ),
                      if (index < _addresses.length - 1)
                        const SizedBox(height: 18),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressHeader extends StatelessWidget {
  const _AddressHeader();

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
                  'Adresse de livraison',
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
                  'Gérer vos lieux de réception',
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

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  final BuyerAddressData address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: address.backgroundColor,
                child: Icon(address.icon, color: address.accentColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.name,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${address.region}, ${address.neighborhood}',
                      style: const TextStyle(
                        color: Color(0xFFA0A8B6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${address.details} • ${address.phone}',
            style: const TextStyle(
              color: Color(0xFF4D596A),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Modifier',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              TextButton(
                onPressed: onDelete,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(
                    color: Color(0xFFF04444),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: address.backgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                address.isPrimary ? 'Adresse par défaut' : 'Secondaire',
                style: TextStyle(
                  color: address.accentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAddresses extends StatelessWidget {
  const _EmptyAddresses();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 70),
      child: Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 48,
            color: Color(0xFFA0A8B6),
          ),
          SizedBox(height: 14),
          Text('Aucune adresse enregistrée'),
        ],
      ),
    );
  }
}

const _initialAddresses = [
  BuyerAddressData(
    name: 'Boutique principale',
    region: 'Dakar',
    city: 'Dakar',
    neighborhood: 'Médina',
    details: 'Rue 22 x 17',
    phone: '77 000 00 00',
    icon: Icons.dns_outlined,
    accentColor: Color(0xFF087C2E),
    backgroundColor: Color(0xFFE5F3EA),
    isPrimary: true,
  ),
  BuyerAddressData(
    name: 'Entrepôt',
    region: 'Pikine',
    city: 'Pikine',
    neighborhood: 'Tally Bou Bess',
    details: 'Près du marché central',
    phone: '76 000 00 00',
    icon: Icons.inventory_2_outlined,
    accentColor: Color(0xFF3478F6),
    backgroundColor: Color(0xFFEDF3FF),
  ),
  BuyerAddressData(
    name: 'Restaurant Teranga',
    region: 'Dakar',
    city: 'Dakar',
    neighborhood: 'Almadies',
    details: 'Route des Almadies',
    phone: '78 000 00 00',
    icon: Icons.restaurant_outlined,
    accentColor: Color(0xFFFF6A00),
    backgroundColor: Color(0xFFFFF0E8),
  ),
];
