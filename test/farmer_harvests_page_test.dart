import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/app/app_routes.dart';
import 'package:yokku_mbey/features/harvests/presentation/pages/farmer_harvests_page.dart';
import 'package:yokku_mbey/features/home/presentation/pages/profile_home_page.dart';
import 'package:yokku_mbey/features/profile_selection/domain/entities/user_profile_type.dart';

void main() {
  testWidgets('opens farmer harvests from the bottom navigation', (
    tester,
  ) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          FarmerHarvestsPage.routeName: (_) => const FarmerHarvestsPage(),
        },
        home: const ProfileHomePage(profileType: UserProfileType.farmer),
      ),
    );

    await tester.tap(find.text('Récoltes'));
    await tester.pumpAndSettle();

    expect(find.byType(FarmerHarvestsPage), findsOneWidget);
    expect(find.text('Mes récoltes'), findsOneWidget);
    expect(find.text('Tomate fraîche'), findsOneWidget);
    expect(find.text('Oignon local'), findsOneWidget);
    expect(find.text('Pomme de terre'), findsOneWidget);
    expect(find.text('Voir'), findsNWidgets(3));
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filters active upcoming and exhausted harvests', (tester) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        routes: AppRoutes.routes,
        initialRoute: FarmerHarvestsPage.routeName,
      ),
    );

    await tester.tap(find.text('Actives'));
    await tester.pump();
    expect(find.text('Tomate fraîche'), findsOneWidget);
    expect(find.text('Oignon local'), findsNothing);

    await tester.tap(find.text('À venir'));
    await tester.pump();
    expect(find.text('Oignon local'), findsOneWidget);
    expect(find.text('Tomate fraîche'), findsNothing);

    await tester.tap(find.text('Épuisées'));
    await tester.pump();
    expect(find.text('Pomme de terre'), findsOneWidget);
    expect(find.text('Oignon local'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

void _setPhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 825);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
