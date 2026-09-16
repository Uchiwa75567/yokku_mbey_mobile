import '../../../../core/widgets/journey_scaffold.dart';
import 'package:flutter/material.dart';

import '../../data/reservation_samples.dart';
import '../../domain/entities/reservation.dart';

enum _ReservationDecision { pending, accepted, refused }

class ReservationDetailPage extends StatefulWidget {
  const ReservationDetailPage({
    super.key,
    required this.reservation,
  });

  static const String routeName = '/reservation-detail';

  final Reservation reservation;

  static Widget fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return ReservationDetailPage(
      reservation:
          arguments is Reservation ? arguments : reservationSamples.first,
    );
  }

  @override
  State<ReservationDetailPage> createState() => _ReservationDetailPageState();
}

class _ReservationDetailPageState extends State<ReservationDetailPage> {
  late _ReservationDecision _decision;

  @override
  void initState() {
    super.initState();
    _decision = widget.reservation.status == ReservationStatus.accepted
        ? _ReservationDecision.accepted
        : _ReservationDecision.pending;
  }

  void _updateDecision(_ReservationDecision decision) {
    setState(() => _decision = decision);

    final message = decision == _ReservationDecision.accepted
        ? 'Réservation acceptée'
        : 'Réservation refusée';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reservation;
    return JourneyScaffold(
        title: 'Détail de la réservation',
        subtitle: r.id,
        children: [
          Text(
              _decision == _ReservationDecision.accepted
                  ? 'Réservation acceptée'
                  : _decision == _ReservationDecision.refused
                      ? 'Réservation refusée'
                      : 'Nouvelle demande',
              style: const TextStyle(
                  color: journeyGreen, fontWeight: FontWeight.w700)),
          const Divider(),
          ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(r.buyerName),
              subtitle: const Text('Acheteur')),
          const JourneyHeading('Commande'),
          Text(r.productName,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          for (final item in <(String, String)>[
            ('Quantité', '${r.quantityKg} kg'),
            ('Prix unitaire', '${r.unitPrice} FCFA / kg'),
            ('Montant total', '${r.totalAmount} FCFA'),
            ('Récupération', r.recoveryMode),
          ])
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Text(item.$1,
                      style: const TextStyle(color: journeyMuted))),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(item.$2,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w600))),
            ]),
          const Divider(),
          const JourneyNotice(
              'Exemple de réservation. Aucun encaissement ni notification réelle ne sera effectué.'),
          if (_decision == _ReservationDecision.pending) ...[
            JourneyButton(
                label: 'Accepter la réservation',
                icon: Icons.check,
                onPressed: () async =>
                    _updateDecision(_ReservationDecision.accepted)),
            OutlinedButton.icon(
                onPressed: () => _updateDecision(_ReservationDecision.refused),
                icon: const Icon(Icons.close),
                label: const Text('Refuser la réservation')),
          ],
        ]);
  }
}
