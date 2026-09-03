import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/app/app_routes.dart';
import 'package:yokku_mbey/features/farmer_services/presentation/pages/farmer_services_pages.dart';

void main() {
  final pages = <String, String>{
    PaymentsWithdrawalsPage.routeName: 'Paiements et retraits',
    MyNeedsPage.routeName: 'Mes besoins',
    WantedProductsPage.routeName: 'Produits recherchés',
    OpportunitiesPage.routeName: 'Opportunités',
    FarmPage.routeName: 'Mon exploitation',
    SettingsPage.routeName: 'Paramètres',
    HelpSupportPage.routeName: 'Aide et support',
    NotificationsPage.routeName: 'Notifications',
  };

  for (final entry in pages.entries) {
    testWidgets('opens ${entry.value}', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          routes: AppRoutes.routes,
          initialRoute: entry.key,
        ),
      );
      await tester.pump();

      expect(find.text(entry.value), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
