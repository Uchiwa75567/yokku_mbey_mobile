import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
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
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(39, 69, 40, 39),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _ProfileHeader(),
                    const SizedBox(height: 32),
                    ...List.generate(ProfileOptions.items.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom:
                              index == ProfileOptions.items.length - 1 ? 0 : 15,
                        ),
                        child: ProfileOptionTile(
                          option: ProfileOptions.items[index],
                          isSelected: index == _selectedIndex,
                          onTap: () => _selectProfile(index),
                        ),
                      );
                    }),
                    const Spacer(),
                    _NextButton(onPressed: _openHome),
                  ],
                ),
              ),
            ),
          ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vous êtes ?',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Choisissez votre profil pour\npersonnaliser votre expérience',
          style: TextStyle(
            color: AppColors.softInk,
            fontSize: 18,
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
      height: 60,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF087C1E),
          foregroundColor: AppColors.white,
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        child: const Text('Suivant'),
      ),
    );
  }
}
