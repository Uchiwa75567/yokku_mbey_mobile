import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../buyer_needs/presentation/pages/buyer_proposals_page.dart';
import '../../../buyer_payments/presentation/pages/buyer_payment_detail_page.dart';
import '../../../buyer_purchases/presentation/pages/buyer_order_tracking_page.dart';

enum _NotificationFilter { all, purchases, needs, payments }

enum _NotificationKind { purchase, need, payment }

class BuyerNotificationsPage extends StatefulWidget {
  const BuyerNotificationsPage({super.key});

  static const String routeName = '/buyer-notifications';

  @override
  State<BuyerNotificationsPage> createState() => _BuyerNotificationsPageState();
}

class _BuyerNotificationsPageState extends State<BuyerNotificationsPage> {
  _NotificationFilter _filter = _NotificationFilter.all;

  List<_BuyerNotification> get _visibleNotifications {
    if (_filter == _NotificationFilter.all) {
      return _notifications;
    }
    final kind = switch (_filter) {
      _NotificationFilter.purchases => _NotificationKind.purchase,
      _NotificationFilter.needs => _NotificationKind.need,
      _NotificationFilter.payments => _NotificationKind.payment,
      _NotificationFilter.all => throw StateError('Filtre inattendu'),
    };
    return _notifications.where((item) => item.kind == kind).toList();
  }

  void _openNotification(_BuyerNotification notification) {
    switch (notification.kind) {
      case _NotificationKind.need:
        Navigator.of(context).pushNamed(
          BuyerProposalsPage.routeName,
          arguments: const BuyerProposalsArguments(
            productName: 'Tomate fraîche',
            quantity: '1 000 kg',
          ),
        );
        return;
      case _NotificationKind.payment:
        Navigator.of(context).pushNamed(
          BuyerPaymentDetailPage.routeName,
          arguments: _samplePayment,
        );
        return;
      case _NotificationKind.purchase:
        Navigator.of(context).pushNamed(
          BuyerOrderTrackingPage.routeName,
          arguments: BuyerOrderTrackingArguments(
            productName: 'Tomate fraîche',
            quantityKg: 200,
            amount: 80000,
            completedSteps: notification.title == 'Commande prête' ? 4 : 2,
          ),
        );
        return;
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
            const SliverToBoxAdapter(child: _NotificationsHeader()),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(18, 26, 18, 18),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Toutes',
                      selected: _filter == _NotificationFilter.all,
                      onTap: () => setState(
                        () => _filter = _NotificationFilter.all,
                      ),
                    ),
                    _FilterChip(
                      label: 'Achats',
                      selected: _filter == _NotificationFilter.purchases,
                      onTap: () => setState(
                        () => _filter = _NotificationFilter.purchases,
                      ),
                    ),
                    _FilterChip(
                      label: 'Demandes',
                      selected: _filter == _NotificationFilter.needs,
                      onTap: () => setState(
                        () => _filter = _NotificationFilter.needs,
                      ),
                    ),
                    _FilterChip(
                      label: 'Paiements',
                      selected: _filter == _NotificationFilter.payments,
                      onTap: () => setState(
                        () => _filter = _NotificationFilter.payments,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(22, 4, 22, 30 + bottomInset),
              sliver: SliverList.separated(
                itemCount: _visibleNotifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final notification = _visibleNotifications[index];
                  return _NotificationCard(
                    notification: notification,
                    onTap: () => _openNotification(notification),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF087C2E),
      padding: const EdgeInsets.fromLTRB(18, 58, 24, 32),
      child: Row(
        children: [
          IconButton.filled(
            tooltip: 'Retour',
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
                  'Notifications',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Suivez vos achats et demandes',
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: selected ? const Color(0xFFF0F8F3) : AppColors.white,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? const Color(0xFF076735) : const Color(0xFFE2E6EB),
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF076735)
                    : const Color(0xFF697386),
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  final _BuyerNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: notification.tint,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: notification.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        color: Color(0xFF191919),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        color: Color(0xFF697386),
                        fontSize: 15,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      notification.time,
                      style: const TextStyle(
                        color: Color(0xFF98A2B3),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFA3ACB8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuyerNotification {
  const _BuyerNotification({
    required this.kind,
    required this.title,
    required this.message,
    required this.time,
    required this.color,
    required this.tint,
  });

  final _NotificationKind kind;
  final String title;
  final String message;
  final String time;
  final Color color;
  final Color tint;
}

const _notifications = [
  _BuyerNotification(
    kind: _NotificationKind.need,
    title: 'Proposition reçue',
    message: 'Ibrahima Ndiaye a répondu à votre demande de tomates.',
    time: 'IL Y A 5 MIN',
    color: Color(0xFF2563EB),
    tint: Color(0xFFEDF4FF),
  ),
  _BuyerNotification(
    kind: _NotificationKind.purchase,
    title: 'Réservation acceptée',
    message: 'Votre réservation de 200 kg a été acceptée.',
    time: 'IL Y A 1 H',
    color: Color(0xFF08715A),
    tint: Color(0xFFEAFAF4),
  ),
  _BuyerNotification(
    kind: _NotificationKind.payment,
    title: 'Paiement confirmé',
    message: 'Le paiement de 80 000 FCFA est confirmé.',
    time: "AUJOURD'HUI",
    color: Color(0xFF08715A),
    tint: Color(0xFFEAFAF4),
  ),
  _BuyerNotification(
    kind: _NotificationKind.purchase,
    title: 'Commande prête',
    message: 'Votre commande est prête pour récupération.',
    time: 'HIER',
    color: Color(0xFFFF6B0B),
    tint: Color(0xFFFFF5E9),
  ),
];

const _samplePayment = BuyerPaymentRecord(
  reference: 'YK-2026-0184',
  transactionNumber: 'WAV-98A72KLM',
  productName: 'Tomate fraîche',
  producerName: 'Ibrahima Ndiaye',
  quantityKg: 200,
  amount: 80000,
  deposit: 0,
  fees: 0,
  method: 'Wave',
  dateLabel: "Aujourd'hui à 10:30",
  status: BuyerPaymentStatus.successful,
);
