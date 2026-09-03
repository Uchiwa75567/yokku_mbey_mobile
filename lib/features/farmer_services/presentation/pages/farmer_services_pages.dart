import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/farmer_glass_surface.dart';
import 'farmer_marketplace_pages.dart';

class PaymentsWithdrawalsPage extends StatelessWidget {
  const PaymentsWithdrawalsPage({super.key});

  static const routeName = '/payments-withdrawals';

  @override
  Widget build(BuildContext context) {
    return _SectionPage(
      title: 'Paiements et retraits',
      subtitle: 'Gérez vos revenus en toute simplicité',
      icon: Icons.account_balance_wallet_outlined,
      hero: const _BalanceHero(),
      actionLabel: 'Demander un retrait',
      onAction: () => _message(context, 'Demande de retrait enregistrée'),
      children: const [
        _SectionTitle('Activité récente'),
        _InfoCard(
          icon: Icons.arrow_downward_rounded,
          iconColor: Color(0xFF087C3A),
          iconBackground: Color(0xFFE8F7EF),
          title: 'Paiement reçu',
          subtitle: 'Marché Central Dakar • Tomate fraîche',
          trailing: '+ 76 000 F',
          trailingColor: Color(0xFF087C3A),
        ),
        _InfoCard(
          icon: Icons.schedule_rounded,
          iconColor: Color(0xFFF28C28),
          iconBackground: Color(0xFFFFF2E2),
          title: 'Paiement en attente',
          subtitle: 'Sokhna Distribution • Oignon local',
          trailing: '175 000 F',
          trailingColor: Color(0xFFF28C28),
        ),
        _InfoCard(
          icon: Icons.arrow_upward_rounded,
          iconColor: Color(0xFF526175),
          iconBackground: Color(0xFFF0F3F6),
          title: 'Retrait Wave',
          subtitle: 'Effectué le 24 juillet',
          trailing: '- 100 000 F',
          trailingColor: Color(0xFF526175),
        ),
      ],
    );
  }
}

class MyNeedsPage extends StatelessWidget {
  const MyNeedsPage({super.key});

  static const routeName = '/my-needs';

  @override
  Widget build(BuildContext context) {
    return _SectionPage(
      title: 'Mes besoins',
      subtitle: 'Publiez ce dont votre exploitation a besoin',
      icon: Icons.chat_bubble_outline_rounded,
      actionLabel: 'Publier un besoin',
      onAction: () => _message(context, 'Nouveau besoin prêt à être publié'),
      children: const [
        _SummaryStrip(
          items: [('3', 'Actifs'), ('8', 'Réponses'), ('1', 'Urgent')],
        ),
        _SectionTitle('Besoins actifs'),
        _InfoCard(
          icon: Icons.agriculture_outlined,
          iconColor: Color(0xFF087C3A),
          iconBackground: Color(0xFFE8F7EF),
          title: 'Location d’un tracteur',
          subtitle: 'Kaolack • Avant le 2 août',
          badge: '4 réponses',
        ),
        _InfoCard(
          icon: Icons.inventory_2_outlined,
          iconColor: Color(0xFF8A5D17),
          iconBackground: Color(0xFFFFF4D9),
          title: 'Caisses de transport',
          subtitle: '50 unités • Livraison souhaitée',
          badge: '3 réponses',
        ),
        _InfoCard(
          icon: Icons.groups_outlined,
          iconColor: Color(0xFF7A4CC2),
          iconBackground: Color(0xFFF2EAFF),
          title: 'Main-d’œuvre récolte',
          subtitle: '6 personnes • 3 jours',
          badge: 'Urgent',
        ),
      ],
    );
  }
}

class WantedProductsPage extends StatelessWidget {
  const WantedProductsPage({super.key});

  static const routeName = '/wanted-products';

  @override
  Widget build(BuildContext context) {
    return _SectionPage(
      title: 'Produits recherchés',
      subtitle: 'Des acheteurs cherchent vos récoltes',
      icon: Icons.search_rounded,
      headerAction: TextButton.icon(
        onPressed: () =>
            Navigator.of(context).pushNamed(SeedSearchPage.routeName),
        icon: const Icon(Icons.spa_outlined),
        label: const Text('Semences'),
      ),
      children: [
        const _SearchPanel(hint: 'Rechercher un produit ou un acheteur'),
        const _SectionTitle('Demandes proches de vous'),
        _InfoCard(
          icon: Icons.local_dining_outlined,
          iconColor: const Color(0xFFE85D04),
          iconBackground: const Color(0xFFFFEEE4),
          title: 'Tomate fraîche',
          subtitle: 'Marché Central Dakar • 500 kg',
          badge: '400 F/kg',
          onTap: () => Navigator.of(context).pushNamed(
            FarmerProductResponsePage.routeName,
            arguments: const FarmerProductResponseData(
              productName: 'Tomate fraîche',
              buyerName: 'Marché Central Dakar',
              requestedQuantity: '500 kg',
              targetPrice: '400 FCFA/kg',
            ),
          ),
        ),
        _InfoCard(
          icon: Icons.eco_outlined,
          iconColor: const Color(0xFF087C3A),
          iconBackground: const Color(0xFFE8F7EF),
          title: 'Oignon local',
          subtitle: 'Sokhna Distribution • 2 tonnes',
          badge: '350 F/kg',
          onTap: () => Navigator.of(context).pushNamed(
            FarmerProductResponsePage.routeName,
            arguments: const FarmerProductResponseData(
              productName: 'Oignon local',
              buyerName: 'Sokhna Distribution',
              requestedQuantity: '2 tonnes',
              targetPrice: '350 FCFA/kg',
            ),
          ),
        ),
        _InfoCard(
          icon: Icons.restaurant_outlined,
          iconColor: const Color(0xFF946C00),
          iconBackground: const Color(0xFFFFF5D6),
          title: 'Pomme de terre',
          subtitle: 'Restaurant Teranga • 300 kg',
          badge: 'À négocier',
          onTap: () => Navigator.of(context).pushNamed(
            FarmerProductResponsePage.routeName,
            arguments: const FarmerProductResponseData(
              productName: 'Pomme de terre',
              buyerName: 'Restaurant Teranga',
              requestedQuantity: '300 kg',
              targetPrice: 'À négocier',
            ),
          ),
        ),
      ],
    );
  }
}

class OpportunitiesPage extends StatelessWidget {
  const OpportunitiesPage({super.key});

  static const routeName = '/opportunities';

  @override
  Widget build(BuildContext context) {
    return const _SectionPage(
      title: 'Opportunités',
      subtitle: 'Développez votre activité agricole',
      icon: Icons.business_center_outlined,
      children: [
        _FeaturedCard(),
        _SectionTitle('Pour vous'),
        _InfoCard(
          icon: Icons.school_outlined,
          iconColor: Color(0xFF2563EB),
          iconBackground: Color(0xFFEAF1FF),
          title: 'Formation en irrigation',
          subtitle: 'Gratuite • Kaolack • 12 août',
          badge: 'Formation',
        ),
        _InfoCard(
          icon: Icons.savings_outlined,
          iconColor: Color(0xFF087C3A),
          iconBackground: Color(0xFFE8F7EF),
          title: 'Financement campagne 2026',
          subtitle: 'Jusqu’à 2 000 000 FCFA',
          badge: 'Financement',
        ),
        _InfoCard(
          icon: Icons.handshake_outlined,
          iconColor: Color(0xFFF28C28),
          iconBackground: Color(0xFFFFF2E2),
          title: 'Coopérative de producteurs',
          subtitle: 'Mutualisez transport et stockage',
          badge: 'Partenariat',
        ),
      ],
    );
  }
}

class FarmPage extends StatelessWidget {
  const FarmPage({super.key});

  static const routeName = '/my-farm';

  @override
  Widget build(BuildContext context) {
    return _SectionPage(
      title: 'Mon exploitation',
      subtitle: 'Les informations de votre ferme',
      icon: Icons.agriculture_outlined,
      actionLabel: 'Modifier mes informations',
      onAction: () => _message(context, 'Modification du profil ouverte'),
      children: const [
        _FarmHero(),
        _SectionTitle('Informations'),
        _InfoCard(
          icon: Icons.location_on_outlined,
          iconColor: Color(0xFF087C3A),
          iconBackground: Color(0xFFE8F7EF),
          title: 'Localisation',
          subtitle: 'Kaolack, Sénégal',
        ),
        _InfoCard(
          icon: Icons.landscape_outlined,
          iconColor: Color(0xFF946C00),
          iconBackground: Color(0xFFFFF5D6),
          title: 'Surface cultivée',
          subtitle: '8,5 hectares',
        ),
        _InfoCard(
          icon: Icons.eco_outlined,
          iconColor: Color(0xFF087C3A),
          iconBackground: Color(0xFFE8F7EF),
          title: 'Cultures principales',
          subtitle: 'Tomate, oignon, pomme de terre',
        ),
      ],
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notifications = true;
  bool sms = true;
  bool biometric = false;

  @override
  Widget build(BuildContext context) {
    return _SectionPage(
      title: 'Paramètres',
      subtitle: 'Personnalisez votre expérience YOKKU',
      icon: Icons.tune_rounded,
      children: [
        const _SectionTitle('Notifications'),
        _ToggleCard(
          icon: Icons.notifications_outlined,
          title: 'Notifications push',
          subtitle: 'Réservations, paiements et opportunités',
          value: notifications,
          onChanged: (value) => setState(() => notifications = value),
        ),
        _ToggleCard(
          icon: Icons.sms_outlined,
          title: 'Alertes par SMS',
          subtitle: 'Recevoir les informations importantes',
          value: sms,
          onChanged: (value) => setState(() => sms = value),
        ),
        const _SectionTitle('Sécurité'),
        _ToggleCard(
          icon: Icons.fingerprint_rounded,
          title: 'Connexion biométrique',
          subtitle: 'Empreinte ou reconnaissance faciale',
          value: biometric,
          onChanged: (value) => setState(() => biometric = value),
        ),
        const _InfoCard(
          icon: Icons.language_rounded,
          iconColor: Color(0xFF526175),
          iconBackground: Color(0xFFF0F3F6),
          title: 'Langue',
          subtitle: 'Français',
          badge: 'Modifier',
        ),
      ],
    );
  }
}

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const routeName = '/help-support';

  @override
  Widget build(BuildContext context) {
    return _SectionPage(
      title: 'Aide et support',
      subtitle: 'Comment pouvons-nous vous aider ?',
      icon: Icons.help_outline_rounded,
      children: [
        const _SearchPanel(hint: 'Rechercher une question'),
        const _SectionTitle('Questions fréquentes'),
        const _InfoCard(
          icon: Icons.sell_outlined,
          iconColor: Color(0xFF087C3A),
          iconBackground: Color(0xFFE8F7EF),
          title: 'Comment publier une récolte ?',
          subtitle: 'Guide rapide en 3 étapes',
        ),
        const _InfoCard(
          icon: Icons.payments_outlined,
          iconColor: Color(0xFFF28C28),
          iconBackground: Color(0xFFFFF2E2),
          title: 'Quand vais-je recevoir mon paiement ?',
          subtitle: 'Délais, commissions et retraits',
        ),
        const _InfoCard(
          icon: Icons.verified_user_outlined,
          iconColor: Color(0xFF2563EB),
          iconBackground: Color(0xFFEAF1FF),
          title: 'Sécurité des transactions',
          subtitle: 'Découvrez la protection YOKKU',
        ),
        const SizedBox(height: 6),
        _SupportBanner(onTap: () => _message(context, 'Support contacté')),
      ],
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  static const routeName = '/notifications';

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool unreadOnly = false;

  @override
  Widget build(BuildContext context) {
    return _SectionPage(
      title: 'Notifications',
      subtitle: 'Restez informé de votre activité',
      icon: Icons.notifications_none_rounded,
      headerAction: TextButton(
        onPressed: () =>
            _message(context, 'Toutes les notifications sont lues'),
        child: const Text('Tout lire'),
      ),
      children: [
        _NotificationFilter(
          value: unreadOnly,
          onChanged: (value) => setState(() => unreadOnly = value),
        ),
        const _SectionTitle('Aujourd’hui'),
        const _NotificationCard(
          icon: Icons.shopping_bag_outlined,
          color: Color(0xFFF28C28),
          title: 'Nouvelle réservation',
          body: 'Marché Central Dakar souhaite réserver 200 kg de tomates.',
          time: 'Il y a 12 min',
          unread: true,
        ),
        const _NotificationCard(
          icon: Icons.payments_outlined,
          color: Color(0xFF087C3A),
          title: 'Paiement reçu',
          body: 'Un paiement de 76 000 FCFA a été ajouté à votre solde.',
          time: 'Il y a 2 h',
          unread: true,
        ),
        if (!unreadOnly) ...const [
          _NotificationCard(
            icon: Icons.star_outline_rounded,
            color: Color(0xFFF59E0B),
            title: 'Nouvel avis',
            body: 'Restaurant Teranga vous a attribué la note de 4,8.',
            time: 'Hier',
          ),
          _NotificationCard(
            icon: Icons.campaign_outlined,
            color: Color(0xFF2563EB),
            title: 'Opportunité pour vous',
            body: 'Une formation gratuite est disponible près de Kaolack.',
            time: 'Hier',
          ),
        ],
      ],
    );
  }
}

class _SectionPage extends StatelessWidget {
  const _SectionPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
    this.hero,
    this.actionLabel,
    this.onAction,
    this.headerAction,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;
  final Widget? hero;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? headerAction;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF18241D),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF18241D),
        body: Stack(
          children: [
            const Positioned.fill(
              child: FarmerGlassBackground(overlayOpacity: 0.46),
            ),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 30),
                    decoration: const BoxDecoration(
                      color: Color(0x99131513),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _BackButton(
                                onTap: () => Navigator.of(context).pop()),
                            const Spacer(),
                            if (headerAction != null)
                              DefaultTextStyle.merge(
                                style: const TextStyle(color: AppColors.white),
                                child: headerAction!,
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child:
                                  Icon(icon, color: AppColors.white, size: 27),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    subtitle,
                                    style: const TextStyle(
                                      color: Color(0xFFD7F2E0),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(18, 20, 18, 24 + bottomInset),
                  sliver: SliverList.list(
                    children: [
                      if (hero != null) ...[hero!, const SizedBox(height: 20)],
                      ...children.expand(
                        (child) => [child, const SizedBox(height: 12)],
                      ),
                      if (actionLabel != null) ...[
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: onAction,
                          icon: const Icon(Icons.add_rounded),
                          label: Text(actionLabel!),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            backgroundColor: const Color(0xFF087C3A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ],
                    ],
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

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.16),
      ),
      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 2),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.trailingColor,
    this.badge,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final String? trailing;
  final Color? trailingColor;
  final String? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8ECE9)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 23),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF7C899B),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: TextStyle(
                    color: trailingColor ?? AppColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                )
              else if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7EF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Color(0xFF087C3A),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFA3ADBA),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceHero extends StatelessWidget {
  const _BalanceHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Solde disponible', style: TextStyle(color: Color(0xFF7C899B))),
          SizedBox(height: 9),
          Text(
            '1 250 000 FCFA',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _MiniMetric('80 000 F', 'En attente')),
              SizedBox(width: 10),
              Expanded(child: _MiniMetric('7 500 F', 'Commission')),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F3),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF7C899B), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.items});
  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 17),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: items
            .map(
              (item) => Expanded(
                child: Column(
                  children: [
                    Text(
                      item.$1,
                      style: const TextStyle(
                        color: Color(0xFF087C3A),
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      item.$2,
                      style: const TextStyle(
                        color: Color(0xFF7C899B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({required this.hint});
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA927), Color(0xFFF27A19)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'APPEL À PROJETS',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Équipez votre exploitation',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Subvention jusqu’à 60 % pour du matériel agricole.',
            style: TextStyle(color: Color(0xFFFFF4DF), height: 1.4),
          ),
          SizedBox(height: 16),
          Text(
            'Candidater avant le 15 août  →',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmHero extends StatelessWidget {
  const _FarmHero();

  @override
  Widget build(BuildContext context) {
    return const _SummaryStrip(
      items: [('8,5 ha', 'Surface'), ('3', 'Cultures'), ('12', 'Récoltes')],
    );
  }
}

class _ToggleCard extends StatelessWidget {
  const _ToggleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF087C3A)),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF7C899B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SupportBanner extends StatelessWidget {
  const _SupportBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0A6F38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.support_agent_rounded, color: AppColors.white),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Besoin d’aide ?',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Notre équipe vous répond rapidement',
                  style: TextStyle(color: Color(0xFFD7F2E0), fontSize: 11),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: const Text(
              'Contacter',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationFilter extends StatelessWidget {
  const _NotificationFilter({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Afficher uniquement les non lues',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unread ? const Color(0xFFF0F9F3) : AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unread ? const Color(0xFFCFE9D7) : const Color(0xFFE8ECE9),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (unread)
                      const CircleAvatar(
                        radius: 4,
                        backgroundColor: Color(0xFF087C3A),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF657286),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFFA0A9B5),
                    fontSize: 10,
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

void _message(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
}
