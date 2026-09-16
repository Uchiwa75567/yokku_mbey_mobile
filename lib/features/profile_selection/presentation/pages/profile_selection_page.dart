import 'package:flutter/material.dart';
import '../../../../core/data/marketplace_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../../../home/presentation/pages/profile_home_page.dart';
import '../../domain/entities/profile_options.dart';
import '../../domain/entities/profile_option.dart';
import '../../domain/entities/user_profile_type.dart';
import '../widgets/profile_option_tile.dart';

class ProfileSelectionPage extends StatefulWidget {
  const ProfileSelectionPage({super.key});
  static const String routeName = '/profile-selection';
  @override
  State<ProfileSelectionPage> createState() => _ProfileSelectionPageState();
}

class _ProfileSelectionPageState extends State<ProfileSelectionPage> {
  int? _selectedIndex;
  bool _confirming = false;
  bool _saving = false;
  String? _error;

  Future<void> _confirmChoice() async {
    if (_selectedIndex == null || _confirming) return;
    final option = ProfileOptions.items[_selectedIndex!];
    final store = MarketplaceScope.maybeOf(context);
    setState(() {
      _confirming = true;
      _error = null;
    });
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 480),
      builder: (_) => _ProfileConfirmation(option: option),
    );
    if (!mounted) return;
    if (confirmed != true) {
      setState(() => _confirming = false);
      return;
    }
    setState(() => _saving = true);
    try {
      await store?.confirmRole(option.type);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
          ProfileHomePage.routeName, (_) => false,
          arguments: option.type);
    } on BusinessException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted) {
        setState(() {
          _confirming = false;
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = MarketplaceScope.maybeOf(context)?.role;
    final current = role == null
        ? null
        : ProfileOptions.items.firstWhere((option) => option.type == role);
    return PopScope(
      canPop: !_saving,
      child: AuthScaffold(back: current != null, children: [
        Text(
            current == null
                ? 'Quel espace souhaitez-vous utiliser ?'
                : 'Changer d’espace',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Text(
            current == null
                ? 'Choisissez votre activité'
                : 'Espace actuel : ${current.title}',
            style: const TextStyle(color: AppColors.softInk, fontSize: 16)),
        const SizedBox(height: 28),
        ...List.generate(
            ProfileOptions.items.length,
            (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProfileOptionTile(
                    option: ProfileOptions.items[index],
                    isSelected: _selectedIndex == index,
                    onTap: _confirming
                        ? null
                        : () => setState(() => _selectedIndex = index)))),
        const SizedBox(height: 20),
        if (_error != null) ...[
          Semantics(
              liveRegion: true,
              child: Text(_error!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error))),
          const SizedBox(height: 12),
        ],
        FilledButton.icon(
            onPressed:
                _selectedIndex == null || _confirming ? null : _confirmChoice,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.arrow_forward, size: 20),
            label: Text(_saving ? 'Enregistrement…' : 'Continuer')),
      ]),
    );
  }
}

class _ProfileConfirmation extends StatelessWidget {
  const _ProfileConfirmation({required this.option});
  final ProfileOption option;

  String get _description => switch (option.type) {
        UserProfileType.farmer =>
          'Publiez vos récoltes, suivez les réservations et trouvez du matériel ou de la main-d’œuvre.',
        UserProfileType.buyer =>
          'Consultez les récoltes disponibles, contactez les agriculteurs et suivez vos commandes.',
        UserProfileType.provider =>
          'Proposez votre travail aux champs, vos services ou votre matériel, puis suivez vos missions.',
        UserProfileType.investor =>
          'Découvrez les projets agricoles et suivez vos intentions de financement.',
      };

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: option.backgroundColor,
                  child: Icon(option.icon, color: option.color, size: 28),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Vous avez choisi'),
              const SizedBox(height: 4),
              Text('Espace ${option.title}',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(_description),
              const SizedBox(height: 24),
              FilledButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.arrow_forward, size: 20),
                  label: const Text('Entrer dans mon espace')),
              const SizedBox(height: 8),
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Modifier mon choix')),
            ],
          ),
        ),
      );
}
