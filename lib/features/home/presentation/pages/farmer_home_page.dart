import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../harvest_publication/presentation/pages/harvest_publication_page.dart';

class FarmerHomePage extends StatelessWidget {
  const FarmerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: _FarmerHomeContent(),
      ),
    );
  }
}

class _FarmerHomeContent extends StatelessWidget {
  const _FarmerHomeContent();

  static const double _designWidth = 440;
  static const double _designHeight = 956;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: SizedBox(
          width: _designWidth,
          height: _designHeight,
          child: _FarmerHomeCanvas(),
        ),
      ),
    );
  }
}

class _FarmerHomeCanvas extends StatelessWidget {
  const _FarmerHomeCanvas();

  void _openPublication(BuildContext context) {
    Navigator.of(context).pushNamed(HarvestPublicationPage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF4F8F3),
      child: Stack(
        children: [
          const _GreenHeader(),
          const _BalanceCard(),
          const _StatsGrid(),
          const _HarvestReminderCard(),
          _QuickActionsSection(
            onPublishHarvest: () => _openPublication(context),
          ),
          const _LastReservationSection(),
          _BottomNavigation(
            onPublishHarvest: () => _openPublication(context),
          ),
        ],
      ),
    );
  }
}

class _GreenHeader extends StatelessWidget {
  const _GreenHeader();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      width: 440,
      height: 276,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B9239),
              Color(0xFF056B2A),
            ],
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 30,
              top: 74,
              right: 92,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Bonjour, Ibrahima',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            height: 1.12,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      Container(
                        width: 31,
                        height: 31,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.touch_app_outlined,
                          color: AppColors.harvest,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Voici votre activité du jour',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.14),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.insights_outlined,
                          color: AppColors.white,
                          size: 15,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Activité du jour',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 29,
              top: 73,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const SizedBox.square(
                    dimension: 48,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFF26944D),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: AppColors.white,
                        size: 27,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B4E),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF056D28),
                          width: 2,
                        ),
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

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 38,
      right: 38,
      top: 158,
      child: Container(
        height: 160,
        padding: const EdgeInsets.fromLTRB(21, 16, 21, 15),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE8F1E8)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF064B1E).withValues(alpha: 0.16),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox.square(
                  dimension: 34,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFFE8FAF2),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Color(0xFF087C4A),
                      size: 19,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Solde disponible',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF6B7890),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Color(0xFFC8D0DB),
                  size: 24,
                ),
              ],
            ),
            SizedBox(height: 7),
            Text(
              '1 250 000 FCFA',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Disponible après les ventes validées',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFFA2ABB9),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
            ),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: _BalancePill(
                    label: 'En attente 80 000',
                    textColor: Color(0xFF007A54),
                    backgroundColor: Color(0xFFE8FAF2),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _BalancePill(
                    label: 'Commission 7 500',
                    textColor: Color(0xFFC34209),
                    backgroundColor: Color(0xFFFFF4E8),
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

class _BalancePill extends StatelessWidget {
  const _BalancePill({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 29,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      left: 38,
      right: 38,
      top: 334,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.inventory_2_outlined,
                  label: 'Récoltes actives',
                  value: '12',
                  color: Color(0xFF087C4A),
                  backgroundColor: Color(0xFFE8F7EF),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.event_available_outlined,
                  label: 'Réservations reçues',
                  value: '18',
                  color: Color(0xFF2563EB),
                  backgroundColor: Color(0xFFEEF3FF),
                ),
              ),
            ],
          ),
          SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_up,
                  label: 'Ventes réalisées',
                  value: '320',
                  color: Color(0xFFFF6B00),
                  backgroundColor: Color(0xFFFFF3E8),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Paiements en attente',
                  value: '24',
                  color: Color(0xFF364256),
                  backgroundColor: Color(0xFFF1F5F9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEFF3EF)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(13, 11, 10, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox.square(
                dimension: 36,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6B7890),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1.05,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HarvestReminderCard extends StatelessWidget {
  const _HarvestReminderCard();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 38,
      right: 38,
      top: 508,
      child: Container(
        height: 72,
        padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5FFFA),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFB8F3D0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF087C4A).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          children: [
            SizedBox.square(
              dimension: 40,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  border: Border.fromBorderSide(
                    BorderSide(color: Color(0xFFB8F3D0)),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.calendar_month_outlined,
                    color: Color(0xFF087C4A),
                    size: 21,
                  ),
                ),
              ),
            ),
            SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2 récoltes bientôt disponibles',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pensez à confirmer leurs dates estimées.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.softInk,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Color(0xFF087C60), size: 18),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({required this.onPublishHarvest});

  final VoidCallback onPublishHarvest;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 36,
      right: 36,
      top: 598,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions rapides',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 17),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QuickAction(
                icon: Icons.add,
                label: 'Ajouter\nune récolte',
                color: const Color(0xFF007A54),
                backgroundColor: const Color(0xFFE6F2EC),
                onTap: onPublishHarvest,
              ),
              const _QuickAction(
                icon: Icons.search,
                label: 'Produits\nrecherchés',
                color: Color(0xFFFF6B00),
                backgroundColor: Color(0xFFFFF3E8),
              ),
              const _QuickAction(
                icon: Icons.chat_bubble_outline,
                label: 'Mes\nbesoins',
                color: Color(0xFF2563EB),
                backgroundColor: Color(0xFFEEF3FF),
              ),
              const _QuickAction(
                icon: Icons.business_outlined,
                label: 'Opportunités',
                color: Color(0xFF364256),
                backgroundColor: Color(0xFFF1F5F9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              SizedBox.square(
                dimension: 60,
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 27),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  height: 1.08,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LastReservationSection extends StatelessWidget {
  const _LastReservationSection();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 36,
      right: 36,
      top: 733,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dernière réservation',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 82,
            padding: const EdgeInsets.fromLTRB(16, 13, 15, 13),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFF0F2F5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Row(
              children: [
                SizedBox.square(
                  dimension: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF6EA),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(9),
                      child: Image(
                        image: AssetImage(AppAssets.buyerTomato),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tomate fraîche • 200 kg',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Acompte reçu : 20 000 FCFA',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                _ReservationStatus(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationStatus extends StatelessWidget {
  const _ReservationStatus();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 29,
      width: 82,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFE8FAF2),
          borderRadius: BorderRadius.circular(99),
        ),
        child: const Center(
          child: Text(
            'Acceptée',
            style: TextStyle(
              color: Color(0xFF007A54),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({required this.onPublishHarvest});

  final VoidCallback onPublishHarvest;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SizedBox(
        height: 68,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BottomNavItem(
                    icon: Icons.home,
                    label: 'Accueil',
                    isActive: true,
                  ),
                  _BottomNavItem(
                    icon: Icons.assignment_turned_in_outlined,
                    label: 'Récoltes',
                  ),
                  SizedBox(width: 58),
                  _BottomNavItem(
                    icon: Icons.favorite_border,
                    label: 'Réservations',
                  ),
                  _BottomNavItem(
                    icon: Icons.person_outline,
                    label: 'Profil',
                  ),
                ],
              ),
              Positioned(
                left: 191,
                top: -34,
                child: GestureDetector(
                  onTap: onPublishHarvest,
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: const Color(0xFF087C4A),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF087C4A).withValues(alpha: 0.22),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child:
                        const Icon(Icons.add, color: AppColors.white, size: 31),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF087C4A) : const Color(0xFF95A2B5);

    return SizedBox(
      width: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
