import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../harvest_publication/presentation/pages/harvest_publication_page.dart';
import '../../../harvests/presentation/pages/farmer_harvests_page.dart';
import '../../../home/presentation/widgets/farmer_bottom_navigation.dart';
import '../../../home/presentation/widgets/farmer_glass_surface.dart';
import '../../../profile/presentation/pages/farmer_profile_page.dart';
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
  static const double _designWidth = 440;
  static const double _designHeight = 1100;
  static const double _navHeight = FarmerBottomNavigation.designHeight;

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
            final scale = (constraints.maxWidth / _designWidth).clamp(0.1, 1.0);
            final width = _designWidth * scale;
            final height = _designHeight * scale;
            final navHeight = _navHeight * scale;
            final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

            return Center(
              child: SizedBox(
                width: width,
                height: constraints.maxHeight,
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: FarmerGlassBackground(overlayOpacity: 0.40),
                    ),
                    SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: navHeight + bottomInset + 18,
                      ),
                      child: SizedBox(
                        width: width,
                        height: height,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            width: _designWidth,
                            height: _designHeight,
                            child: _ReservationsCanvas(
                              selectedFilter: _selectedFilter,
                              requests: _visibleRequests,
                              onFilterChanged: (filter) {
                                setState(() => _selectedFilter = filter);
                              },
                              onViewRequest: _showRequest,
                              onRejectRequest: _rejectRequest,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: bottomInset,
                      height: navHeight,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        alignment: Alignment.bottomLeft,
                        child: SizedBox(
                          width: _designWidth,
                          height: _navHeight,
                          child: FarmerBottomNavigation(
                            activeTab: FarmerNavigationTab.reservations,
                            onHome: () => Navigator.of(context).maybePop(),
                            onPublishHarvest: () => Navigator.of(context)
                                .pushNamed(HarvestPublicationPage.routeName),
                            onHarvests: () =>
                                Navigator.of(context).pushReplacementNamed(
                              FarmerHarvestsPage.routeName,
                            ),
                            onProfile: () => Navigator.of(context)
                                .pushNamed(FarmerProfilePage.routeName),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ReservationsCanvas extends StatelessWidget {
  const _ReservationsCanvas({
    required this.selectedFilter,
    required this.requests,
    required this.onFilterChanged,
    required this.onViewRequest,
    required this.onRejectRequest,
  });

  final _ReservationFilter selectedFilter;
  final List<Reservation> requests;
  final ValueChanged<_ReservationFilter> onFilterChanged;
  final ValueChanged<Reservation> onViewRequest;
  final ValueChanged<Reservation> onRejectRequest;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 74,
          child: FarmerGlassSurface(
            color: Color(0x1AFFFFFF),
            blurSigma: 16,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(26),
            ),
            borderColor: Color(0x33FFFFFF),
            child: _ReservationsHeader(),
          ),
        ),
        const Positioned(
          left: 18,
          right: 18,
          top: 94,
          height: 126,
          child: _ReservationOverview(requests: reservationSamples),
        ),
        Positioned(
          left: 18,
          right: 18,
          top: 242,
          height: 39,
          child: _ReservationFilters(
            selectedFilter: selectedFilter,
            onChanged: onFilterChanged,
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          top: 302,
          child: requests.isEmpty
              ? const _EmptyReservations()
              : Column(
                  children: requests.indexed.map((entry) {
                    final index = entry.$1;
                    final request = entry.$2;
                    return Padding(
                      padding: EdgeInsets.only(top: index == 0 ? 0 : 15),
                      child: _ReservationCard(
                        request: request,
                        onViewRequest: () => onViewRequest(request),
                        onRejectRequest: () => onRejectRequest(request),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

class _ReservationsHeader extends StatelessWidget {
  const _ReservationsHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Icon(Icons.menu_rounded, color: AppColors.white, size: 22),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Réservations reçues',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _NotificationButton(),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0x33FFFFFF),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              color: AppColors.white,
              size: 22,
            ),
            Positioned(
              right: 9,
              top: 8,
              child: SizedBox.square(
                dimension: 7,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFFFF6B00),
                    shape: BoxShape.circle,
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

class _ReservationOverview extends StatelessWidget {
  const _ReservationOverview({required this.requests});

  final List<Reservation> requests;

  @override
  Widget build(BuildContext context) {
    final pendingCount = requests
        .where((request) => request.status == ReservationStatus.newRequest)
        .length;
    final totalAmount = requests.fold<int>(
      0,
      (sum, request) => sum + request.totalAmount,
    );

    return FarmerGlassSurface(
      color: const Color(0x99191C1D),
      blurSigma: 20,
      borderRadius: BorderRadius.circular(24),
      borderColor: const Color(0x26FFFFFF),
      boxShadow: const [
        BoxShadow(
          color: Color(0x24000000),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 17, 20, 15),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _OverviewValue(
                    label: 'À confirmer',
                    value: '$pendingCount',
                    valueColor: const Color(0xFFFF6B00),
                  ),
                ),
                Expanded(
                  child: _OverviewValue(
                    label: 'Valeur totale',
                    value: '${_formatCompactAmount(totalAmount)} F',
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Divider(height: 1, color: Color(0x33FFFFFF)),
            const Spacer(),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total de demandes',
                    style: TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${requests.length} Demandes',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewValue extends StatelessWidget {
  const _OverviewValue({
    required this.label,
    required this.value,
    this.valueColor = AppColors.white,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xB3FFFFFF),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ReservationFilters extends StatelessWidget {
  const _ReservationFilters({
    required this.selectedFilter,
    required this.onChanged,
  });

  final _ReservationFilter selectedFilter;
  final ValueChanged<_ReservationFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterButton(
          label: 'Nouvelles',
          selected: selectedFilter == _ReservationFilter.newRequests,
          onTap: () => onChanged(_ReservationFilter.newRequests),
        ),
        const SizedBox(width: 8),
        _FilterButton(
          label: 'Acceptées',
          selected: selectedFilter == _ReservationFilter.accepted,
          onTap: () => onChanged(_ReservationFilter.accepted),
        ),
        const SizedBox(width: 8),
        _FilterButton(
          label: 'En cours',
          selected: selectedFilter == _ReservationFilter.inProgress,
          onTap: () => onChanged(_ReservationFilter.inProgress),
        ),
        const SizedBox(width: 8),
        _FilterButton(
          label: 'Terminées',
          selected: selectedFilter == _ReservationFilter.completed,
          onTap: () => onChanged(_ReservationFilter.completed),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? const Color(0xFF007D40) : Colors.transparent,
        borderRadius: BorderRadius.circular(99),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(99),
          child: FarmerGlassSurface(
            color: selected ? const Color(0xFF007D40) : const Color(0x1AFFFFFF),
            blurSigma: 16,
            borderRadius: BorderRadius.circular(99),
            borderColor:
                selected ? const Color(0xFF007D40) : const Color(0x33FFFFFF),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.request,
    required this.onViewRequest,
    required this.onRejectRequest,
  });

  final Reservation request;
  final VoidCallback onViewRequest;
  final VoidCallback onRejectRequest;

  @override
  Widget build(BuildContext context) {
    final isNew = request.status == ReservationStatus.newRequest;

    return SizedBox(
      height: 228,
      child: FarmerGlassSurface(
        color: const Color(0x99191C1D),
        blurSigma: 20,
        borderRadius: BorderRadius.circular(18),
        borderColor: const Color(0x26FFFFFF),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                request.buyerName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  height: 1.12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatusBadge(status: request.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${request.productName} • ${request.quantityKg} kg',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xB3FFFFFF),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_formatAmount(request.totalAmount)}\nFCFA',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color:
                              isNew ? const Color(0xFF92F8AD) : AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        request.paymentDetails,
                        style: TextStyle(
                          color: request.status == ReservationStatus.accepted
                              ? const Color(0xFF37D56A)
                              : const Color(0x80FFFFFF),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  if (isNew) ...[
                    Expanded(
                      child: _CardAction(
                        label: 'Rejeter',
                        onTap: onRejectRequest,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: _CardAction(
                      label: 'Voir la demande',
                      onTap: onViewRequest,
                      isPrimary: isNew,
                      showArrow: !isNew,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Divider(height: 1, color: Color(0x26FFFFFF)),
              const SizedBox(height: 9),
              Row(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    color: Color(0xB3FFFFFF),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      request.recoveryMode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xB3FFFFFF),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${_formatAmount(request.unitPrice)} FCFA/kg',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  const Icon(
                    Icons.history_rounded,
                    color: Color(0x80FFFFFF),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${request.transactionCount} transactions avec cet acheteur',
                    style: const TextStyle(
                      color: Color(0x80FFFFFF),
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.showArrow = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? const Color(0xFF006131) : const Color(0x1AFFFFFF),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (showArrow) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.white,
                  size: 14,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ReservationStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, backgroundColor) = switch (status) {
      ReservationStatus.newRequest => (
          'NOUVELLE',
          const Color(0xFFFF8A1F),
          const Color(0x33FF6B00),
        ),
      ReservationStatus.accepted => (
          'ACCEPTÉE',
          const Color(0xFF37D56A),
          const Color(0x3322C55E),
        ),
      ReservationStatus.pending => (
          'EN ATTENTE',
          const Color(0xFFFFD166),
          const Color(0x33FFD166),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 7,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyReservations extends StatelessWidget {
  const _EmptyReservations();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 190,
      child: FarmerGlassSurface(
        color: const Color(0x99191C1D),
        blurSigma: 20,
        borderRadius: BorderRadius.circular(18),
        borderColor: const Color(0x26FFFFFF),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, color: Color(0xB3FFFFFF), size: 38),
            SizedBox(height: 13),
            Text(
              'Aucune réservation dans cette catégorie',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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

String _formatCompactAmount(int value) {
  if (value >= 1000000) {
    final amount = value / 1000000;
    return '${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 1)} M';
  }
  if (value >= 1000) {
    return '${(value / 1000).round()} k';
  }
  return value.toString();
}
