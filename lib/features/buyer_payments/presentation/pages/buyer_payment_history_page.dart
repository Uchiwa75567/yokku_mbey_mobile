import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import 'buyer_payment_detail_page.dart';

enum _PaymentFilter { all, successful, pending }

class BuyerPaymentHistoryPage extends StatefulWidget {
  const BuyerPaymentHistoryPage({super.key});

  static const String routeName = '/buyer-payment-history';

  @override
  State<BuyerPaymentHistoryPage> createState() =>
      _BuyerPaymentHistoryPageState();
}

class _BuyerPaymentHistoryPageState extends State<BuyerPaymentHistoryPage> {
  _PaymentFilter _filter = _PaymentFilter.all;

  List<BuyerPaymentRecord> get _visiblePayments {
    return switch (_filter) {
      _PaymentFilter.all => _payments,
      _PaymentFilter.successful => _payments
          .where((payment) => payment.status == BuyerPaymentStatus.successful)
          .toList(),
      _PaymentFilter.pending => _payments
          .where((payment) => payment.status == BuyerPaymentStatus.pending)
          .toList(),
    };
  }

  void _openPayment(BuyerPaymentRecord payment) {
    Navigator.of(context).pushNamed(
      BuyerPaymentDetailPage.routeName,
      arguments: payment,
    );
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
            const SliverToBoxAdapter(child: _PaymentHistoryHeader()),
            SliverPersistentHeader(
              pinned: true,
              delegate: _PaymentFiltersDelegate(
                selected: _filter,
                onChanged: (value) => setState(() => _filter = value),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(36, 20, 36, 30 + bottomInset),
              sliver: _visiblePayments.isEmpty
                  ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text('Aucun paiement')),
                    )
                  : SliverList.separated(
                      itemCount: _visiblePayments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 18),
                      itemBuilder: (context, index) {
                        final payment = _visiblePayments[index];
                        return _PaymentCard(
                          payment: payment,
                          onView: () => _openPayment(payment),
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

class _PaymentHistoryHeader extends StatelessWidget {
  const _PaymentHistoryHeader();

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
                  'Historique des paiements',
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
                  'Retrouvez toutes vos transactions',
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

class _PaymentFiltersDelegate extends SliverPersistentHeaderDelegate {
  const _PaymentFiltersDelegate({
    required this.selected,
    required this.onChanged,
  });

  final _PaymentFilter selected;
  final ValueChanged<_PaymentFilter> onChanged;

  @override
  double get minExtent => 73;

  @override
  double get maxExtent => 73;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
        child: Row(
          children: [
            _FilterButton(
              label: 'Toutes',
              selected: selected == _PaymentFilter.all,
              onTap: () => onChanged(_PaymentFilter.all),
            ),
            const SizedBox(width: 8),
            _FilterButton(
              label: 'Réussis',
              selected: selected == _PaymentFilter.successful,
              onTap: () => onChanged(_PaymentFilter.successful),
            ),
            const SizedBox(width: 8),
            _FilterButton(
              label: 'En attente',
              selected: selected == _PaymentFilter.pending,
              onTap: () => onChanged(_PaymentFilter.pending),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_PaymentFiltersDelegate oldDelegate) {
    return oldDelegate.selected != selected;
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
      child: SizedBox(
        height: 43,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor:
                selected ? const Color(0xFFF0F8F4) : AppColors.white,
            foregroundColor:
                selected ? const Color(0xFF06723B) : const Color(0xFF697386),
            side: BorderSide(
              color:
                  selected ? const Color(0xFF06723B) : const Color(0xFFE6E9EE),
              width: selected ? 2 : 1,
            ),
            shape: const StadiumBorder(),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w800 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment, required this.onView});

  final BuyerPaymentRecord payment;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final visual = _statusVisual(payment.status);
    return Container(
      height: 170,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 17,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: visual.background,
            child: Text(
              'F',
              style: TextStyle(
                color: visual.color,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF172748),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  payment.producerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFA0A8B6)),
                ),
                const Spacer(),
                Text(
                  '${_formatAmount(payment.amount)} FCFA • ${payment.method}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF172748),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  payment.dateLabel,
                  style: const TextStyle(
                    color: Color(0xFFA0A8B6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: visual.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  visual.label,
                  style: TextStyle(
                    color: visual.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onView,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(52, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Voir ›',
                  style: TextStyle(
                    color: Color(0xFF076735),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

typedef _StatusVisual = ({
  String label,
  Color color,
  Color background,
});

_StatusVisual _statusVisual(BuyerPaymentStatus status) {
  return switch (status) {
    BuyerPaymentStatus.successful => (
        label: 'Réussi',
        color: const Color(0xFF317D55),
        background: const Color(0xFFE5F3EA),
      ),
    BuyerPaymentStatus.pending => (
        label: 'En attente',
        color: const Color(0xFFF28C00),
        background: const Color(0xFFFFF2E2),
      ),
    BuyerPaymentStatus.failed => (
        label: 'Échoué',
        color: const Color(0xFFD92D2D),
        background: const Color(0xFFFFE7E7),
      ),
  };
}

const _payments = [
  BuyerPaymentRecord(
    reference: 'YK-2026-0184',
    transactionNumber: 'WAV-98A72KLM',
    productName: 'Tomate fraîche',
    producerName: 'Ibrahima Ndiaye',
    quantityKg: 200,
    amount: 80000,
    deposit: 0,
    fees: 0,
    method: 'Wave',
    dateLabel: "Aujourd'hui, 10:30",
    status: BuyerPaymentStatus.successful,
  ),
  BuyerPaymentRecord(
    reference: 'YK-2026-0185',
    transactionNumber: 'OM-14B92QPK',
    productName: 'Oignon local',
    producerName: 'Moussa Fall',
    quantityKg: 100,
    amount: 35000,
    deposit: 7000,
    fees: 0,
    method: 'Orange Money',
    dateLabel: 'Hier, 16:10',
    status: BuyerPaymentStatus.pending,
  ),
  BuyerPaymentRecord(
    reference: 'YK-2026-0169',
    transactionNumber: 'WAV-72C51ABC',
    productName: 'Pomme de terre',
    producerName: 'Aminata Ba',
    quantityKg: 100,
    amount: 50000,
    deposit: 0,
    fees: 0,
    method: 'Wave',
    dateLabel: '12 juin, 09:20',
    status: BuyerPaymentStatus.failed,
  ),
];

String _formatAmount(int value) {
  return value.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ' ',
      );
}
