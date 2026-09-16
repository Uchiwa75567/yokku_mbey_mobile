import 'package:flutter/material.dart';
import 'package:yokku_mbey/app/app_routes.dart';
import 'package:yokku_mbey/core/theme/app_theme.dart';
import 'package:yokku_mbey/core/data/marketplace_store.dart';
import 'package:yokku_mbey/features/profile_selection/domain/entities/user_profile_type.dart';

MarketplaceStore testStore(UserProfileType role) {
  final store = MarketplaceStore(persistence: MemoryWorkspacePersistence());
  store.requestCode('+221771234567');
  store.verifyCode('1234');
  store.selectRole(role);
  return store;
}

Widget marketplaceTestApp(
        {required MarketplaceStore store,
        String route = '/home',
        Object? arguments,
        double textScale = 1}) =>
    MarketplaceScope(
        store: store,
        child: MaterialApp(
          key: ValueKey('${store.role}:$route:$arguments:$textScale'),
          theme: AppTheme.light.copyWith(
              textTheme: AppTheme.light.textTheme.apply(fontFamily: 'Roboto')),
          debugShowCheckedModeBanner: false,
          routes: AppRoutes.routes,
          initialRoute: route,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!),
          onGenerateInitialRoutes: (_) => [
            MaterialPageRoute<void>(
                settings: RouteSettings(name: route, arguments: arguments),
                builder: AppRoutes.routes[route]!)
          ],
        ));
