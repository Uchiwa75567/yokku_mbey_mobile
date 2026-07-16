import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile_selection/domain/entities/user_profile_type.dart';
import '../../domain/entities/profile_home_content.dart';
import '../../domain/entities/profile_home_contents.dart';
import 'buyer_home_page.dart';
import 'farmer_home_page.dart';

class ProfileHomePage extends StatelessWidget {
  const ProfileHomePage({
    required this.profileType,
    super.key,
  });

  static const String routeName = '/home';

  final UserProfileType profileType;

  static ProfileHomePage fromRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final profileType = args is UserProfileType ? args : UserProfileType.farmer;

    return ProfileHomePage(profileType: profileType);
  }

  @override
  Widget build(BuildContext context) {
    if (profileType == UserProfileType.farmer) {
      return const FarmerHomePage();
    }

    if (profileType == UserProfileType.buyer) {
      return const BuyerHomePage();
    }

    final content = ProfileHomeContents.byProfileType(profileType);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: _ProfileHomeContent(content: content),
        ),
      ),
    );
  }
}

class _ProfileHomeContent extends StatelessWidget {
  const _ProfileHomeContent({required this.content});

  final ProfileHomeContent content;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 760;
        final contentWidth = math.min(constraints.maxWidth, 390.0);

        return Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  28,
                  isCompact ? 30 : 44,
                  28,
                  isCompact ? 24 : 32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HomeHeader(content: content),
                    SizedBox(height: isCompact ? 24 : 30),
                    _GuidanceCard(content: content),
                    SizedBox(height: isCompact ? 22 : 28),
                    const Text(
                      'Actions rapides',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: isCompact ? 14 : 18),
                    ...List.generate(content.actions.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == content.actions.length - 1 ? 0 : 12,
                        ),
                        child: _HomeActionTile(action: content.actions[index]),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.content});

  final ProfileHomeContent content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox.square(
              dimension: 44,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.greenSoft,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Icon(
                  Icons.home_outlined,
                  color: AppColors.leaf,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                content.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.08,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          content.subtitle,
          style: const TextStyle(
            color: AppColors.softInk,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            height: 1.35,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard({required this.content});

  final ProfileHomeContent content;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.selectedOptionBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBAF2CD)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content.guidanceTitle,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              content.guidanceText,
              style: const TextStyle(
                color: AppColors.mutedInk,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeActionTile extends StatelessWidget {
  const _HomeActionTile({required this.action});

  final ProfileHomeAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.optionBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 82,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: action.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      action.icon,
                      color: action.color,
                      size: 27,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        action.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.softInk,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.15,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.inputHint,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
