import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/external_contact_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../buyer_reviews/presentation/pages/buyer_rate_transaction_page.dart';
import '../../../buyer_support/presentation/pages/buyer_report_problem_page.dart';

class BuyerOrderTrackingArguments {
  const BuyerOrderTrackingArguments({
    required this.productName,
    required this.quantityKg,
    required this.amount,
    this.orderNumber = 'YK-2026-0184',
    this.producerName = 'Ibrahima Ndiaye',
    this.producerPhone = '+221 77 000 00 00',
    this.completedSteps = 3,
  });

  final String productName;
  final int quantityKg;
  final int amount;
  final String orderNumber;
  final String producerName;
  final String producerPhone;
  final int completedSteps;
}

class BuyerOrderTrackingPage extends StatelessWidget {
  const BuyerOrderTrackingPage({
    super.key,
    required this.arguments,
  });

  static const String routeName = '/buyer-order-tracking';

  final BuyerOrderTrackingArguments arguments;

  static Widget fromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return BuyerOrderTrackingPage(
      arguments: arguments is BuyerOrderTrackingArguments
          ? arguments
          : const BuyerOrderTrackingArguments(
              productName: 'Tomate fraîche',
              quantityKg: 200,
              amount: 80000,
            ),
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
            SliverToBoxAdapter(child: _Header(arguments: arguments)),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(43, 25, 43, 30 + bottomInset),
              sliver: SliverList.list(
                children: [
                  _OrderSummary(arguments: arguments),
                  const SizedBox(height: 28),
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Progression',
                      style: TextStyle(
                        color: Color(0xFF062532),
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: _OrderTimeline(
                      completedSteps: arguments.completedSteps,
                    ),
                  ),
                  const SizedBox(height: 34),
                  const Divider(color: Color(0xFFF0F2F4)),
                  const SizedBox(height: 16),
                  if (arguments.completedSteps >= 5) ...[
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed(
                        BuyerRateTransactionPage.routeName,
                        arguments: BuyerRateTransactionArguments(
                          productName: arguments.productName,
                          quantityKg: arguments.quantityKg,
                          producerName: arguments.producerName,
                        ),
                      ),
                      icon: const Icon(Icons.star_rounded),
                      label: const Text(
                        'Noter la transaction',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        backgroundColor: const Color(0xFFFFB51B),
                        foregroundColor: const Color(0xFF172748),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  FilledButton(
                    onPressed: () => ExternalContactService.showContactOptions(
                      context,
                      phoneNumber: arguments.producerPhone,
                      contactName: arguments.producerName,
                      message:
                          'Bonjour, je vous contacte au sujet de la commande ${arguments.orderNumber} sur YOKKU MBEY.',
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: const Color(0xFF076735),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Appeler ou WhatsApp',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pushNamed(
                      BuyerReportProblemPage.routeName,
                      arguments: BuyerReportProblemArguments(
                        reference: 'Commande ${arguments.orderNumber}',
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      foregroundColor: const Color(0xFF076735),
                      side: const BorderSide(
                        color: Color(0xFF076735),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Signaler un problème',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.arguments});

  final BuyerOrderTrackingArguments arguments;

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
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              fixedSize: const Size(48, 48),
            ),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Suivi de la commande',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  arguments.orderNumber,
                  style: const TextStyle(
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

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.arguments});

  final BuyerOrderTrackingArguments arguments;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FAF5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${arguments.productName} • ${arguments.quantityKg} kg',
            style: const TextStyle(
              color: Color(0xFF062532),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${_formatAmount(arguments.amount)} FCFA • Producteur : ${arguments.producerName}',
            style: const TextStyle(
              color: Color(0xFF819BA5),
              fontSize: 15,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  const _OrderTimeline({required this.completedSteps});

  final int completedSteps;

  static const double _markerSize = 24;
  static const double _stepGap = 70;
  static const double _timelineHeight = 304;

  static const _steps = [
    ('Réservation envoyée', "Aujourd'hui, 09:30"),
    ("Acceptée par l'agriculteur", "Aujourd'hui, 10:10"),
    ('Produit en préparation', "Prévu aujourd'hui"),
    ('Prête pour récupération', 'En attente'),
    ('Transaction terminée', 'En attente'),
  ];

  @override
  Widget build(BuildContext context) {
    final safeCompletedSteps = completedSteps.clamp(0, _steps.length);
    return SizedBox(
      height: _timelineHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _TimelineAxisPainter(
                markerRadius: _markerSize / 2,
                stepGap: _stepGap,
                stepCount: _steps.length,
                completedSteps: safeCompletedSteps,
              ),
            ),
          ),
          ...List.generate(_steps.length, (index) {
            return Positioned(
              top: index * _stepGap,
              left: 0,
              right: 0,
              child: _TimelineStep(
                key: ValueKey('order-timeline-step-$index'),
                title: _steps[index].$1,
                subtitle: _steps[index].$2,
                completed: index < safeCompletedSteps,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.completed,
  });

  final String title;
  final String subtitle;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            key: ValueKey(
              completed
                  ? 'timeline-marker-completed'
                  : 'timeline-marker-pending',
            ),
            width: _OrderTimeline._markerSize,
            height: _OrderTimeline._markerSize,
            decoration: BoxDecoration(
              color: completed ? const Color(0xFF08713B) : AppColors.white,
              shape: BoxShape.circle,
              border: completed
                  ? null
                  : Border.all(
                      color: const Color(0xFF95A7BE),
                      width: 2,
                    ),
            ),
            child: completed
                ? const Icon(
                    Icons.check_rounded,
                    color: AppColors.white,
                    size: 17,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF062532),
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF86A0AA),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineAxisPainter extends CustomPainter {
  const _TimelineAxisPainter({
    required this.markerRadius,
    required this.stepGap,
    required this.stepCount,
    required this.completedSteps,
  });

  final double markerRadius;
  final double stepGap;
  final int stepCount;
  final int completedSteps;

  @override
  void paint(Canvas canvas, Size size) {
    final x = markerRadius;
    final firstCenter = markerRadius;
    final lastCenter = markerRadius + (stepCount - 1) * stepGap;
    final greyPaint = Paint()
      ..color = const Color(0xFFDCE3EA)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(
      Offset(x, firstCenter),
      Offset(x, lastCenter),
      greyPaint,
    );

    if (completedSteps > 1) {
      final lastCompletedCenter = markerRadius + (completedSteps - 1) * stepGap;
      final greenPaint = Paint()
        ..color = const Color(0xFF08713B)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.square;
      canvas.drawLine(
        Offset(x, firstCenter),
        Offset(x, lastCompletedCenter),
        greenPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_TimelineAxisPainter oldDelegate) {
    return oldDelegate.completedSteps != completedSteps ||
        oldDelegate.stepCount != stepCount ||
        oldDelegate.stepGap != stepGap ||
        oldDelegate.markerRadius != markerRadius;
  }
}

String _formatAmount(int value) {
  return value.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ' ',
      );
}
