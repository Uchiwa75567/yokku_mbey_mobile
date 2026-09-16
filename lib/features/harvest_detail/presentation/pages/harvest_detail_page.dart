import '../../../../core/widgets/journey_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../harvest_boost/presentation/pages/harvest_boost_page.dart';
import '../../../harvest_edit/presentation/pages/harvest_edit_page.dart';

class HarvestDetailPage extends StatefulWidget {
  const HarvestDetailPage({super.key});

  static const String routeName = '/harvest-detail';

  @override
  State<HarvestDetailPage> createState() => _HarvestDetailPageState();
}

class _HarvestDetailPageState extends State<HarvestDetailPage> {
  static const String _listingLink =
      'https://yokkumbey.sn/recoltes/tomate-fraiche';

  bool _isFavorite = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _copyListingLink() async {
    await Clipboard.setData(const ClipboardData(text: _listingLink));
    if (mounted) {
      _showMessage('Lien de l’annonce copié');
    }
  }

  Future<void> _shareListing() async {
    await Clipboard.setData(const ClipboardData(text: _listingLink));
    if (mounted) {
      _showMessage('Lien prêt à être partagé');
    }
  }

  @override
  Widget build(BuildContext context) => JourneyScaffold(
        title: 'Détail de la récolte',
        actions: [
          IconButton(
              tooltip: 'Favori',
              onPressed: () => setState(() => _isFavorite = !_isFavorite),
              icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: journeyGreen)),
          IconButton(
              tooltip: 'Partager',
              onPressed: _shareListing,
              icon: const Icon(Icons.share_outlined)),
        ],
        leading: AspectRatio(
            aspectRatio: 1.7,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(AppAssets.harvestTomatoDetail,
                    fit: BoxFit.cover))),
        bottom: Row(children: [
          Expanded(
              child: OutlinedButton.icon(
                  onPressed: () => openJourney(
                      context, HarvestEditPage.routeName,
                      arguments: HarvestEditPage.defaultHarvest),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Modifier'))),
          const SizedBox(width: 12),
          Expanded(
              child: FilledButton.icon(
                  onPressed: () => openJourney(
                      context, HarvestBoostPage.routeName,
                      arguments: HarvestBoostPage.defaultHarvest),
                  icon: const Icon(Icons.trending_up, size: 18),
                  label: const Text('Booster'))),
        ]),
        children: [
          const Text('Disponible', style: TextStyle(color: journeyGreen)),
          const Text('Tomate fraîche',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: journeyInk)),
          const Text('400 FCFA / kg',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: journeyGreen)),
          const Text('500 kg disponibles · Kaolack'),
          const Divider(),
          const JourneyHeading('Informations'),
          const Text('Commande minimum : 100 kg'),
          const Text('Retrait sur place ou livraison à convenir.'),
          const Divider(),
          const JourneyHeading('Description'),
          const Text(
              'Tomates fraîches récoltées localement, disponibles pour vos achats en gros.'),
          TextButton.icon(
              onPressed: _copyListingLink,
              icon: const Icon(Icons.link),
              label: const Text('Copier le lien')),
          const JourneyNotice(
              'Annonce de démonstration. Les statistiques et paiements ne sont pas connectés.'),
        ],
      );
}
