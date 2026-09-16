import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/app/app_routes.dart';
import 'package:yokku_mbey/features/harvest_boost/presentation/pages/harvest_boost_page.dart';
import 'package:yokku_mbey/features/harvests/presentation/pages/farmer_harvests_page.dart';

void main() {
  testWidgets('opens boost page from a farmer harvest card', (tester) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        routes: AppRoutes.routes,
        initialRoute: FarmerHarvestsPage.routeName,
      ),
    );

    await tester.ensureVisible(find.text('Booster').first);
    await tester.tap(find.text('Booster').first);
    await tester.pumpAndSettle();

    expect(find.byType(HarvestBoostPage), findsOneWidget);
    expect(find.text('Booster ma récolte'), findsOneWidget);
    expect(find.text('Tomate fraîche'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changes boost plan and selects a payment method',
      (tester) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        routes: AppRoutes.routes,
        initialRoute: HarvestBoostPage.routeName,
      ),
    );

    await tester.ensureVisible(find.text('Boost 24 h'));
    await tester.tap(find.text('Boost 24 h'));
    await tester.pump();
    expect(find.text('Continuer'), findsOneWidget);

    await tester.ensureVisible(find.text('Wave / Orange Money / Carte'));
    await tester.tap(find.text('Wave / Orange Money / Carte'));
    await tester.pumpAndSettle();
    expect(find.text('Wave'), findsOneWidget);
    expect(find.text('Orange Money'), findsOneWidget);
    expect(find.text('Carte bancaire'), findsOneWidget);

    await tester.ensureVisible(find.text('Wave'));
    await tester.tap(find.text('Wave'));
    await tester.pumpAndSettle();
    expect(find.text('Wave'), findsOneWidget);

    await tester.ensureVisible(find.text('Continuer'));
    await tester.tap(find.text('Continuer'));
    await tester.pump();
    expect(find.textContaining('Aperçu : 500 FCFA via Wave'), findsOneWidget);
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
