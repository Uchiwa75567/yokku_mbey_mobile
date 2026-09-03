import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

class BuyerPersonalInfoPage extends StatefulWidget {
  const BuyerPersonalInfoPage({super.key});
  static const routeName = '/buyer-personal-info';

  @override
  State<BuyerPersonalInfoPage> createState() => _BuyerPersonalInfoPageState();
}

class _BuyerPersonalInfoPageState extends State<BuyerPersonalInfoPage> {
  final _name = TextEditingController(text: 'Awa DIOP');
  final _phone = TextEditingController(text: '77 000 00 00');
  final _email = TextEditingController(text: 'awa.diop@yokku.sn');
  final _city = TextEditingController(text: 'Dakar');

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BuyerPageShell(
      title: 'Informations personnelles',
      subtitle: 'Gérez votre profil acheteur',
      children: [
        const Center(
          child: CircleAvatar(
            radius: 46,
            backgroundColor: Color(0xFFE8F6ED),
            child:
                Icon(Icons.person_rounded, size: 48, color: Color(0xFF08713B)),
          ),
        ),
        const SizedBox(height: 28),
        _FormField(label: 'Nom complet', controller: _name),
        _FormField(
          label: 'Téléphone',
          controller: _phone,
          keyboardType: TextInputType.phone,
        ),
        _FormField(
          label: 'Adresse e-mail',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        _FormField(label: 'Ville', controller: _city),
        const SizedBox(height: 18),
        _PrimaryButton(
          label: 'Enregistrer les modifications',
          onPressed: () => _confirmation(context, 'Profil mis à jour'),
        ),
      ],
    );
  }
}

class BuyerSettingsPage extends StatefulWidget {
  const BuyerSettingsPage({super.key});
  static const routeName = '/buyer-settings';

  @override
  State<BuyerSettingsPage> createState() => _BuyerSettingsPageState();
}

class _BuyerSettingsPageState extends State<BuyerSettingsPage> {
  bool _purchaseNotifications = true;
  bool _needNotifications = true;
  bool _priceAlerts = true;
  bool _biometrics = false;

  @override
  Widget build(BuildContext context) {
    return _BuyerPageShell(
      title: 'Paramètres',
      subtitle: 'Personnalisez votre expérience',
      children: [
        const _SectionTitle('Notifications'),
        _SettingSwitch(
          title: 'Suivi des achats',
          subtitle: 'Évolution de vos commandes',
          value: _purchaseNotifications,
          onChanged: (value) => setState(() => _purchaseNotifications = value),
        ),
        _SettingSwitch(
          title: 'Réponses à mes demandes',
          subtitle: 'Nouvelles propositions reçues',
          value: _needNotifications,
          onChanged: (value) => setState(() => _needNotifications = value),
        ),
        _SettingSwitch(
          title: 'Alertes de prix',
          subtitle: 'Produits correspondant à vos critères',
          value: _priceAlerts,
          onChanged: (value) => setState(() => _priceAlerts = value),
        ),
        const SizedBox(height: 24),
        const _SectionTitle('Sécurité et préférences'),
        _SettingSwitch(
          title: 'Connexion biométrique',
          subtitle: 'Empreinte digitale ou reconnaissance faciale',
          value: _biometrics,
          onChanged: (value) => setState(() => _biometrics = value),
        ),
        const _StaticSetting(title: 'Langue', value: 'Français'),
        const _StaticSetting(title: 'Devise', value: 'FCFA'),
        const SizedBox(height: 30),
        OutlinedButton(
          onPressed: () => _confirmation(context, 'Session déconnectée'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            foregroundColor: const Color(0xFFF04444),
          ),
          child: const Text('Se déconnecter'),
        ),
      ],
    );
  }
}

class BuyerHelpSupportPage extends StatelessWidget {
  const BuyerHelpSupportPage({super.key});
  static const routeName = '/buyer-help-support';

  @override
  Widget build(BuildContext context) {
    return _BuyerPageShell(
      title: 'Aide et support',
      subtitle: 'Nous sommes là pour vous aider',
      children: [
        TextField(
          decoration: _inputDecoration('Rechercher une question').copyWith(
            prefixIcon: const Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 26),
        const _SectionTitle('Questions fréquentes'),
        const _Faq(
          question: 'Comment réserver un produit ?',
          answer:
              'Ouvrez une fiche produit, choisissez la quantité puis suivez les étapes de paiement.',
        ),
        const _Faq(
          question: 'Comment suivre ma commande ?',
          answer: 'Retrouvez toutes les étapes dans Profil, puis Mes achats.',
        ),
        const _Faq(
          question: 'Que faire en cas de problème ?',
          answer:
              'Utilisez le bouton Signaler un problème depuis le suivi ou le paiement.',
        ),
        const SizedBox(height: 24),
        const _SectionTitle('Contacter le support'),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: const CircleAvatar(
            backgroundColor: Color(0xFFE8F6ED),
            child: Icon(Icons.phone_outlined, color: Color(0xFF08713B)),
          ),
          title: const Text('Assistance YOKKU'),
          subtitle: const Text('Du lundi au samedi, 8h–18h'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => _confirmation(context, 'Demande de rappel enregistrée'),
        ),
      ],
    );
  }
}

class BuyerReputationPage extends StatelessWidget {
  const BuyerReputationPage({super.key});
  static const routeName = '/buyer-reputation';

  @override
  Widget build(BuildContext context) {
    return const _BuyerPageShell(
      title: 'Avis et réputation',
      subtitle: 'Votre crédibilité sur YOKKU',
      children: [
        _RatingSummary(),
        SizedBox(height: 28),
        _SectionTitle('Détails'),
        _RatingLine(label: 'Paiements ponctuels', value: '5,0'),
        _RatingLine(label: 'Respect des engagements', value: '4,9'),
        _RatingLine(label: 'Communication', value: '4,8'),
        SizedBox(height: 28),
        _SectionTitle('Derniers avis reçus'),
        _ReviewCard(
          author: 'Ibrahima Ndiaye',
          rating: '5,0',
          comment:
              'Acheteuse sérieuse, paiement rapide et récupération à l’heure.',
        ),
        _ReviewCard(
          author: 'Moussa Fall',
          rating: '4,8',
          comment: 'Transaction fluide et quantités respectées.',
        ),
      ],
    );
  }
}

class _BuyerPageShell extends StatelessWidget {
  const _BuyerPageShell({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: const Color(0xFF087C2E),
                padding: const EdgeInsets.fromLTRB(18, 58, 24, 32),
                child: Row(
                  children: [
                    IconButton.filled(
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        fixedSize: const Size(48, 48),
                        backgroundColor: Colors.white.withValues(alpha: .3),
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
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
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
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(28, 28, 28, 30 + bottomInset),
              sliver: SliverList.list(children: children),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    this.keyboardType,
  });
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: _labelStyle),
            const SizedBox(height: 9),
            TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: _inputDecoration(label),
            ),
          ],
        ),
      );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: const Color(0xFF076735),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      );
}

class _SettingSwitch extends StatelessWidget {
  const _SettingSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        value: value,
        activeTrackColor: const Color(0xFF08713B),
        onChanged: onChanged,
      );
}

class _StaticSetting extends StatelessWidget {
  const _StaticSetting({required this.title, required this.value});
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Text(value), const Icon(Icons.chevron_right_rounded)],
        ),
      );
}

class _Faq extends StatelessWidget {
  const _Faq({required this.question, required this.answer});
  final String question;
  final String answer;
  @override
  Widget build(BuildContext context) => ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(answer, style: const TextStyle(height: 1.4)),
          ),
        ],
      );
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FAF5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          children: [
            Text('4,9',
                style: TextStyle(fontSize: 52, fontWeight: FontWeight.w900)),
            Text('★★★★★',
                style: TextStyle(color: Color(0xFFFFB51B), fontSize: 26)),
            SizedBox(height: 8),
            Text('18 avis reçus', style: TextStyle(color: Color(0xFF697386))),
          ],
        ),
      );
}

class _RatingLine extends StatelessWidget {
  const _RatingLine({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        trailing: Text(
          '$value ★',
          style: const TextStyle(
            color: Color(0xFFFF8A34),
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.author,
    required this.rating,
    required this.comment,
  });
  final String author;
  final String rating;
  final String comment;
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 14),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title:
              Text(author, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(comment),
          ),
          trailing: Text(
            '$rating ★',
            style: const TextStyle(color: Color(0xFFFF8A34)),
          ),
        ),
      );
}

const _labelStyle = TextStyle(
  color: Color(0xFF344054),
  fontWeight: FontWeight.w800,
);

InputDecoration _inputDecoration(String hint) => InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFDDE3EA)),
      ),
    );

void _confirmation(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
