import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/auth_premium_surface.dart';
import '../../../home/presentation/pages/profile_home_page.dart';
import '../../domain/entities/profile_options.dart';
import '../widgets/profile_option_tile.dart';

class ProfileSelectionPage extends StatefulWidget {
  const ProfileSelectionPage({super.key});

  static const String routeName = '/profile-selection';

  @override
  State<ProfileSelectionPage> createState() => _ProfileSelectionPageState();
}

class _ProfileSelectionPageState extends State<ProfileSelectionPage> {
  int _selectedIndex = ProfileOptions.defaultSelectedIndex;

  void _selectProfile(int index) {
    setState(() => _selectedIndex = index);
  }

  void _openHome() {
    Navigator.of(context).pushReplacementNamed(
      ProfileHomePage.routeName,
      arguments: ProfileOptions.items[_selectedIndex].type,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.forestDeep,
        body: Stack(
          children: [
            const Positioned.fill(
              child: AuthPremiumBackground(overlayOpacity: 0.34),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: 350,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 18, 8, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _ProfileHeader(),
                              const SizedBox(height: 18),
                              ...List.generate(
                                ProfileOptions.items.length,
                                (index) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom:
                                        index == ProfileOptions.items.length - 1
                                            ? 0
                                            : 9,
                                  ),
                                  child: ProfileOptionTile(
                                    option: ProfileOptions.items[index],
                                    isSelected: index == _selectedIndex,
                                    onTap: () => _selectProfile(index),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _NextButton(onPressed: _openHome),
                            ],
                          ),
                        ),
                      ),
                    ),
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Vous êtes ?',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 7),
        Text(
          'Choisissez votre profil pour personnaliser\nvotre expérience',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFE1EAE3),
            fontSize: 11,
            fontWeight: FontWeight.w400,
            height: 1.25,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF087C1E),
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        child: const Text('Suivant'),
      ),
    );
  }
}
