import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/data/marketplace_store.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/profile_selection/presentation/pages/profile_selection_page.dart';
import '../features/profile_selection/domain/entities/user_profile_type.dart';
import '../features/home/presentation/pages/profile_home_page.dart';
import 'app_routes.dart';

class YokkuMbeyApp extends StatefulWidget {
  const YokkuMbeyApp({this.store, super.key});
  final MarketplaceStore? store;

  @override
  State<YokkuMbeyApp> createState() => _YokkuMbeyAppState();
}

class _YokkuMbeyAppState extends State<YokkuMbeyApp> {
  late final MarketplaceStore store = widget.store ??
      MarketplaceStore(persistence: MemoryWorkspacePersistence());

  @override
  void dispose() {
    if (widget.store == null) store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MarketplaceScope(
        store: store,
        child: MaterialApp(
          title: 'Yokku Mbey',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routes: AppRoutes.routes.map((name, builder) => MapEntry(
              name, (context) => _SessionRoute(name: name, builder: builder))),
          initialRoute: AppRoutes.splash,
          builder: (context, child) {
            return ColoredBox(
              color: AppColors.white,
              child: SafeArea(
                top: true,
                bottom: false,
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        ));
  }
}

class _SessionRoute extends StatelessWidget {
  const _SessionRoute({required this.name, required this.builder});
  final String name;
  final WidgetBuilder builder;
  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.of(context);
    if (store.loadError != null) {
      return Scaffold(
          body: Center(
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(store.loadError!),
                    const SizedBox(height: 16),
                    FilledButton(
                        onPressed: store.load, child: const Text('Réessayer'))
                  ]))));
    }
    if ([AppRoutes.splash, AppRoutes.login, AppRoutes.verification]
        .contains(name)) {
      return builder(context);
    }
    if (store.phone == null) return const LoginPage();
    if (name == AppRoutes.profileSelection) return builder(context);
    if (!store.signedIn) return const ProfileSelectionPage();
    final expected = name.startsWith('/buyer-') ||
            ['/product-reservation', '/pre-reservation', '/publish-buyer-need']
                .contains(name)
        ? UserProfileType.buyer
        : name.startsWith('/investor-')
            ? UserProfileType.investor
            : name.startsWith('/provider-')
                ? UserProfileType.provider
                : name == '/home' ||
                        name.startsWith('/account-') ||
                        name == '/service-request-detail' ||
                        name == '/record-detail'
                    ? null
                    : UserProfileType.farmer;
    if (expected != null && expected != store.role) {
      return ProfileHomePage(profileType: store.role!);
    }
    return builder(context);
  }
}
