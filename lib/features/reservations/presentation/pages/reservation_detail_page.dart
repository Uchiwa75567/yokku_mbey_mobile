import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/farmer_glass_surface.dart';
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF18241D),
        body: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 440,
              height: 956,
              child: _ReservationDetailCanvas(
                reservation: widget.reservation,
                decision: _decision,
                onBack: () => Navigator.of(context).maybePop(),
                onAccept: () => _updateDecision(_ReservationDecision.accepted),
                onRefuse: () => _updateDecision(_ReservationDecision.refused),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReservationDetailCanvas extends StatelessWidget {
  const _ReservationDetailCanvas({
    required this.reservation,
    required this.decision,
    required this.onBack,
    required this.onAccept,
    required this.onRefuse,
  });

  final Reservation reservation;
  final _ReservationDecision decision;
  final VoidCallback onBack;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: FarmerGlassBackground(overlayOpacity: 0.46),
        ),
        Positioned(
          left: 12,
          right: 12,
          top: 48,
          bottom: 24,
          child: FarmerGlassSurface(
            color: const Color(0xE6FFFFFF),
            blurSigma: 20,
            borderRadius: BorderRadius.circular(28),
            borderColor: const Color(0x66FFFFFF),
            child: const SizedBox.expand(),
          ),
        ),
        Positioned(
          left: 29,
          right: 24,
          top: 70,
          child: Row(
            children: [
              _BackButton(onPressed: onBack),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Détail de la réservation',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 36,
          right: 46,
          top: 121,
          child: _StatusBanner(decision: decision),
        ),
        Positioned(
          left: 29,
          right: 53,
          top: 209,
          child: _BuyerSection(reservation: reservation),
        ),
        const Positioned(
          left: 29,
          right: 53,
          top: 291,
          child: Divider(height: 1, color: Color(0xFFE8EBF0)),
        ),
        Positioned(
          left: 29,
          right: 53,
          top: 320,
          child: _ReservationSummary(reservation: reservation),
        ),
        Positioned(
          left: 29,
          right: 53,
          top: 545,
          child: _EstimatedNetCard(reservation: reservation),
        ),
        Positioned(
          left: 29,
          right: 53,
          top: 680,
          child: _RecoverySection(mode: reservation.recoveryMode),
        ),
        Positioned(
          left: 29,
          right: 53,
          bottom: 55,
          child: decision == _ReservationDecision.pending
              ? _DecisionButtons(onRefuse: onRefuse, onAccept: onAccept)
              : _DecisionConfirmation(
                  accepted: decision == _ReservationDecision.accepted,
                  onBack: onBack,
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
      dimension: 40,
      child: Material(
        color: const Color(0xFF9AC99C),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: const Icon(
            Icons.chevron_left,
            color: AppColors.white,
            size: 33,
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.decision});

  final _ReservationDecision decision;

  @override
  Widget build(BuildContext context) {
    final (label, color, backgroundColor, borderColor) = switch (decision) {
      _ReservationDecision.pending => (
          'Nouvelle réservation à traiter',
          const Color(0xFFFF6B0B),
          const Color(0xFFFFF8EF),
          const Color(0xFFFFE1BD),
        ),
      _ReservationDecision.accepted => (
          'Réservation acceptée',
          const Color(0xFF087C3A),
          const Color(0xFFEAF7EF),
          const Color(0xFFC9EAD6),
        ),
      _ReservationDecision.refused => (
          'Réservation refusée',
          const Color(0xFFE43E45),
          const Color(0xFFFFF1F2),
          const Color(0xFFFFD1D4),
        ),
    };

    return Container(
      height: 54,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _BuyerSection extends StatelessWidget {
  const _BuyerSection({required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acheteur',
          style: TextStyle(
            color: Color(0xFF6D7789),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          reservation.buyerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 7),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Acheteur vérifié',
                style: TextStyle(
                  color: Color(0xFF069B65),
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: ' • ${reservation.transactionCount} transactions',
                style: const TextStyle(color: Color(0xFF6D7789)),
              ),
            ],
          ),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _ReservationSummary extends StatelessWidget {
  const _ReservationSummary({required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SummaryRow(label: 'Produit', value: reservation.productName),
        const SizedBox(height: 18),
        _SummaryRow(
          label: 'Quantité',
          value: '${reservation.quantityKg} kg',
        ),
        const SizedBox(height: 18),
        _SummaryRow(
          label: 'Prix unitaire',
          value: '${_formatAmount(reservation.unitPrice)} FCFA',
        ),
        const SizedBox(height: 18),
        _SummaryRow(
          label: 'Montant total',
          value: '${_formatAmount(reservation.totalAmount)} FCFA',
          emphasize: true,
        ),
        const SizedBox(height: 18),
        _SummaryRow(
          label: 'Acompte reçu',
          value: '${_formatAmount(reservation.depositAmount)} FCFA',
          valueColor: const Color(0xFF069B65),
        ),
        const SizedBox(height: 18),
        _SummaryRow(
          label: 'Reste à payer',
          value: '${_formatAmount(reservation.remainingAmount)} FCFA',
          valueColor: const Color(0xFFFF6B0B),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor = AppColors.ink,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9AA9C0),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor,
              fontSize: emphasize ? 18 : 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _EstimatedNetCard extends StatelessWidget {
  const _EstimatedNetCard({required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Montant net estimé',
                  style: TextStyle(
                    color: Color(0xFF9AA9C0),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_formatAmount(reservation.estimatedNetAmount)} FCFA',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: SizedBox(
              width: 122,
              child: Text(
                'Commission : ${_formatAmount(reservation.commissionAmount)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF9AA9C0),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecoverySection extends StatelessWidget {
  const _RecoverySection({required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mode de récupération',
          style: TextStyle(
            color: Color(0xFF6D7789),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          mode,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _DecisionButtons extends StatelessWidget {
  const _DecisionButtons({required this.onRefuse, required this.onAccept});

  final VoidCallback onRefuse;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 54,
            child: OutlinedButton(
              onPressed: onRefuse,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFF0444A),
                side: const BorderSide(color: Color(0xFFFF6267)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              child: const Text('Refuser'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: onAccept,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF075A2B),
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              child: const Text('Accepter'),
            ),
          ),
        ),
      ],
    );
  }
}

class _DecisionConfirmation extends StatelessWidget {
  const _DecisionConfirmation({required this.accepted, required this.onBack});

  final bool accepted;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: onBack,
        style: FilledButton.styleFrom(
          backgroundColor:
              accepted ? const Color(0xFF075A2B) : const Color(0xFFF0444A),
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        icon:
            Icon(accepted ? Icons.check_circle_outline : Icons.cancel_outlined),
        label: Text(
          accepted ? 'Retour aux réservations' : 'Réservation refusée - Retour',
        ),
      ),
    );
  }
}

String _formatAmount(int value) {
  return value.toString().replaceAllMapped(
        RegExp(r'(?=(\d{3})+(?!\d))'),
        (_) => ' ',
      );
}
