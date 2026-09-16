import 'package:flutter/material.dart';
import '../data/marketplace_models.dart';
import '../data/marketplace_store.dart';
import '../../features/home/presentation/widgets/farmer_bottom_navigation.dart';
import '../../features/home/presentation/widgets/buyer_bottom_navigation.dart';
import '../../features/profile_selection/domain/entities/user_profile_type.dart';

const journeyGreen = Color(0xFF126344);
const journeyInk = Color(0xFF171D28);
const journeyMuted = Color(0xFF667180);
const journeyBorder = Color(0xFFE2E7EC);

void openJourney(BuildContext context, String route, {Object? arguments}) {
  Navigator.of(context).pushNamed(route, arguments: arguments);
}

void openJourneyTab(BuildContext context, String route) {
  if (ModalRoute.of(context)?.settings.name == route) return;
  final navigator = Navigator.of(context);
  if (route == '/home') {
    navigator.popUntil((r) => r.settings.name == '/home' || r.isFirst);
  } else {
    navigator.pushNamedAndRemoveUntil(
        route, (r) => r.settings.name == '/home' || r.isFirst);
  }
}

Future<bool> runJourneyAction(
    BuildContext context, Future<void> Function() action,
    {String? success}) async {
  try {
    await action();
    if (context.mounted && success != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(success)));
    }
    return true;
  } on BusinessException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
    return false;
  }
}

Future<void> logout(BuildContext context) async {
  final store = MarketplaceScope.maybeOf(context);
  final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
            title: const Text('Se déconnecter ?'),
            content: const Text(
                'Vos données enregistrées seront conservées pour votre prochaine connexion.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Rester connecté')),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Se déconnecter'))
            ],
          ));
  if (confirmed != true || !context.mounted) return;
  store?.signOut();
  Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
}

class JourneyScaffold extends StatelessWidget {
  const JourneyScaffold(
      {required this.title,
      required this.children,
      this.subtitle,
      this.tab = 0,
      this.root = false,
      this.actions = const [],
      this.bottom,
      this.homeHeader = false,
      this.leading,
      this.profileType,
      super.key});
  final String title;
  final String? subtitle;
  final List<Widget> children, actions;
  final int tab;
  final bool root, homeHeader;
  final Widget? bottom, leading;
  final UserProfileType? profileType;

  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.maybeOf(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: bottom == null && !root,
        child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (root) ...[
                        Row(children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text('Yokku Mbey',
                                    style: TextStyle(
                                        color: journeyGreen,
                                        fontSize: homeHeader ? 28 : 21,
                                        fontWeight: FontWeight.w800)),
                                Text(
                                    'Espace ${(store?.role ?? profileType)?.label.toLowerCase() ?? 'agriculteur'}',
                                    style: const TextStyle(
                                        color: journeyMuted, fontSize: 13)),
                              ])),
                          ...actions,
                          IconButton(
                              tooltip: 'Notifications',
                              onPressed: () => openJourney(
                                  context,
                                  store?.role == UserProfileType.farmer
                                      ? '/notifications'
                                      : '/account-notifications'),
                              icon: const Icon(
                                  Icons.notifications_none_outlined)),
                        ]),
                        const SizedBox(height: 24),
                        if (!homeHeader)
                          Text(title,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: journeyInk)),
                      ] else ...[
                        Row(children: [
                          IconButton(
                              tooltip: 'Retour',
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Icon(Icons.arrow_back)),
                          const SizedBox(width: 4),
                          Expanded(
                              child: Text(title,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: journeyInk))),
                          ...actions,
                        ]),
                      ],
                      if (subtitle != null && !homeHeader) ...[
                        const SizedBox(height: 8),
                        Text(subtitle!,
                            style: const TextStyle(
                                color: journeyMuted, height: 1.5)),
                      ],
                      if (!homeHeader) const SizedBox(height: 24),
                      if (leading != null) ...[
                        leading!,
                        const SizedBox(height: 20)
                      ],
                      ...children
                          .expand((w) => [w, const SizedBox(height: 16)]),
                    ]),
              ),
            )),
      ),
      bottomNavigationBar: root
          ? SafeArea(
              top: false,
              child: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child:
                          _RoleNavigation(tab: tab, profileType: profileType))))
          : bottom == null
              ? null
              : SafeArea(
                  top: false,
                  child: Center(
                      heightFactor: 1,
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 12, 20, 12),
                              child: bottom!)))),
    );
  }
}

class _RoleNavigation extends StatelessWidget {
  const _RoleNavigation({required this.tab, this.profileType});
  final int tab;
  final UserProfileType? profileType;
  @override
  Widget build(BuildContext context) {
    final role = MarketplaceScope.maybeOf(context)?.role ??
        profileType ??
        UserProfileType.farmer;
    if (role == UserProfileType.farmer) {
      return FarmerBottomNavigation(
          activeTab: FarmerNavigationTab.values[tab],
          onHome: () => openJourneyTab(context, '/home'),
          onHarvests: () => openJourneyTab(context, '/farmer-harvests'),
          onReservations: () =>
              openJourneyTab(context, '/reservations-received'),
          onProfile: () => openJourneyTab(context, '/farmer-profile'),
          onPublishHarvest: () => openJourney(context, '/publish-harvest'));
    }
    final investor = role == UserProfileType.investor;
    if (role == UserProfileType.buyer) {
      return BuyerBottomNavigation(
          activeTab: BuyerNavigationTab.values[tab],
          onHome: () => openJourneyTab(context, '/home'),
          onSearch: () => openJourneyTab(context, '/buyer-products'),
          onReservations: () => openJourneyTab(context, '/buyer-purchases'),
          onProfile: () => openJourneyTab(context, '/buyer-profile'),
          onPrimaryAction: () => openJourney(context, '/publish-buyer-need'));
    }
    return FarmerBottomNavigation(
        activeTab: FarmerNavigationTab.values[tab],
        secondLabel: investor ? 'Projets' : 'Services',
        thirdLabel: investor ? 'Suivi' : 'Missions',
        secondIcon: investor ? Icons.eco_outlined : Icons.agriculture_outlined,
        secondActiveIcon: investor ? Icons.eco : Icons.agriculture,
        thirdIcon: investor
            ? Icons.account_balance_wallet_outlined
            : Icons.assignment_outlined,
        thirdActiveIcon:
            investor ? Icons.account_balance_wallet : Icons.assignment,
        actionLabel: investor ? 'Soutenir un projet' : 'Ajouter un service',
        onHome: () => openJourneyTab(context, '/home'),
        onHarvests: () => openJourneyTab(
            context, investor ? '/investor-projects' : '/provider-services'),
        onReservations: () => openJourneyTab(
            context, investor ? '/investor-funding' : '/provider-jobs'),
        onProfile: () => openJourneyTab(context, '/account-profile'),
        onPublishHarvest: () => openJourney(context,
            investor ? '/investor-projects' : '/provider-service-form'));
  }
}

class JourneyCard extends StatelessWidget {
  const JourneyCard(
      {required this.child,
      this.onTap,
      this.padding = const EdgeInsets.all(16),
      super.key});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: journeyBorder)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
          onTap: onTap, child: Padding(padding: padding, child: child)));
}

class JourneyHeading extends StatelessWidget {
  const JourneyHeading(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: journeyInk, fontSize: 19, fontWeight: FontWeight.w700));
}

class JourneyNotice extends StatelessWidget {
  const JourneyNotice(this.text, {this.icon = Icons.info_outline, super.key});
  final String text;
  final IconData icon;
  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: const Color(0xFF226A91), size: 20),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: const TextStyle(color: journeyMuted, height: 1.5))),
      ]);
}

class JourneyEmpty extends StatelessWidget {
  const JourneyEmpty(
      {required this.title, required this.message, this.action, super.key});
  final String title, message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(children: [
        const Icon(Icons.inbox_outlined, color: journeyMuted, size: 42),
        const SizedBox(height: 16),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: journeyInk, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: journeyMuted, height: 1.5)),
        if (action != null) ...[const SizedBox(height: 20), action!],
      ]));
}

class JourneyButton extends StatefulWidget {
  const JourneyButton(
      {required this.label,
      required this.onPressed,
      this.icon = Icons.arrow_forward_rounded,
      super.key});
  final String label;
  final Future<void> Function()? onPressed;
  final IconData icon;
  @override
  State<JourneyButton> createState() => _JourneyButtonState();
}

class _JourneyButtonState extends State<JourneyButton> {
  bool _busy = false;
  @override
  Widget build(BuildContext context) => FilledButton.icon(
        style: FilledButton.styleFrom(
            backgroundColor: journeyGreen,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: _busy || widget.onPressed == null
            ? null
            : () async {
                setState(() => _busy = true);
                try {
                  await runJourneyAction(context, widget.onPressed!);
                } finally {
                  if (mounted) setState(() => _busy = false);
                }
              },
        icon: _busy
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Icon(widget.icon, size: 20),
        label: Text(widget.label, textAlign: TextAlign.center),
      );
}

class JourneyField extends StatelessWidget {
  const JourneyField(
      {required this.label,
      required this.controller,
      this.number = false,
      this.lines = 1,
      this.required = true,
      super.key});
  final String label;
  final TextEditingController controller;
  final bool number, required;
  final int lines;
  @override
  Widget build(BuildContext context) => TextFormField(
      controller: controller,
      maxLines: lines,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Color(0xFF172C21), fontSize: 16),
      decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF8FAFB),
          labelStyle: const TextStyle(color: Color(0xFF42554A)),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          floatingLabelStyle: const TextStyle(
              color: journeyMuted, backgroundColor: Colors.white),
          alignLabelWithHint: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return 'Champ obligatoire';
        }
        if (number && (int.tryParse(value ?? '') ?? 0) <= 0) {
          return 'Indiquez un nombre entier positif';
        }
        return null;
      });
}

class JourneySelect extends StatelessWidget {
  const JourneySelect(
      {required this.label,
      required this.value,
      required this.values,
      required this.onChanged,
      super.key});
  final String label, value;
  final List<String> values;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
      key: ValueKey('$label:$value'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          floatingLabelStyle: const TextStyle(
              color: journeyMuted, backgroundColor: Colors.white),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
      items: values
          .map((v) => DropdownMenuItem(
              value: v, child: Text(v, overflow: TextOverflow.ellipsis)))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      });
}

class RecordTile extends StatelessWidget {
  const RecordTile({required this.record, required this.onTap, super.key});
  final MarketRecord record;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => JourneyCard(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(record.title,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700))),
          const Icon(Icons.chevron_right, color: journeyGreen)
        ]),
        const SizedBox(height: 8),
        Text([
          if (record.region.isNotEmpty) record.region,
          if (record.quantity > 0)
            '${record.quantity} ${record.attributes['unit'] ?? 'kg'}',
          if (record.amount > 0) formatCfa(record.amount)
        ].join(' · ')),
        const SizedBox(height: 10),
        Text('${record.status.label} · ${formatDate(record.createdAt)}',
            style: const TextStyle(
                color: journeyGreen, fontWeight: FontWeight.w600)),
      ]));
}
