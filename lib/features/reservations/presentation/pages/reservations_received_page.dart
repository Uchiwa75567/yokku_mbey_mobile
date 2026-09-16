import '../../../../core/widgets/journey_scaffold.dart';
import 'package:flutter/material.dart';

import '../../data/reservation_samples.dart';
import '../../domain/entities/reservation.dart';
import 'reservation_detail_page.dart';

enum _ReservationFilter { newRequests, accepted, inProgress, completed }

class ReservationsReceivedPage extends StatefulWidget {
  const ReservationsReceivedPage({super.key});

  static const String routeName = '/reservations-received';

  @override
  State<ReservationsReceivedPage> createState() =>
      _ReservationsReceivedPageState();
}

class _ReservationsReceivedPageState extends State<ReservationsReceivedPage> {
  _ReservationFilter _selectedFilter = _ReservationFilter.newRequests;

  List<Reservation> get _visibleRequests {
    return switch (_selectedFilter) {
      _ReservationFilter.newRequests => reservationSamples,
      _ReservationFilter.accepted => reservationSamples
          .where((request) => request.status == ReservationStatus.accepted)
          .toList(),
      _ReservationFilter.inProgress => reservationSamples
          .where((request) => request.status == ReservationStatus.pending)
          .toList(),
      _ReservationFilter.completed => const [],
    };
  }

  void _showRequest(Reservation request) {
    Navigator.of(context).pushNamed(
      ReservationDetailPage.routeName,
      arguments: request,
    );
  }

  void _rejectRequest(Reservation request) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Demande de ${request.buyerName} rejetée'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) => JourneyScaffold(
          title: 'Réservations reçues',
          root: true,
          tab: 2,
          children: [
            Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _ReservationFilter.values
                    .map((f) => ChoiceChip(
                        label: Text([
                          'Nouvelles',
                          'Acceptées',
                          'En cours',
                          'Terminées'
                        ][f.index]),
                        selected: f == _selectedFilter,
                        onSelected: (_) => setState(() => _selectedFilter = f)))
                    .toList()),
            if (_visibleRequests.isEmpty)
              const JourneyEmpty(
                  title: 'Aucune réservation',
                  message:
                      'Les réservations de cette catégorie apparaîtront ici.'),
            for (final request in _visibleRequests)
              JourneyCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      const CircleAvatar(
                          backgroundColor: Color(0xFFEAF3FB),
                          child: Icon(Icons.person_outline,
                              color: Color(0xFF226A91))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(request.buyerName,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w700))),
                    ]),
                    const SizedBox(height: 16),
                    Text(request.productName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(
                        '${request.quantityKg} kg · ${request.totalAmount} FCFA'),
                    const SizedBox(height: 6),
                    Text(request.recoveryMode,
                        style: const TextStyle(color: journeyMuted)),
                    const SizedBox(height: 16),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      FilledButton.icon(
                          onPressed: () => _showRequest(request),
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: const Text('Voir la demande')),
                      OutlinedButton.icon(
                          onPressed: () => _rejectRequest(request),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Refuser')),
                    ]),
                  ])),
            const JourneyNotice(
                'Demandes de démonstration, sans échange avec un acheteur réel.'),
          ]);
}
