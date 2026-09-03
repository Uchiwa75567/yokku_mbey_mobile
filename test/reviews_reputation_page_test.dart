import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/app/app_routes.dart';
import 'package:yokku_mbey/features/profile/presentation/pages/farmer_profile_page.dart';
import 'package:yokku_mbey/features/reviews/presentation/pages/reviews_reputation_page.dart';

void main() {
  testWidgets('opens reviews and reputation from the farmer profile', (
    tester,
  ) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        routes: AppRoutes.routes,
        initialRoute: FarmerProfilePage.routeName,
      ),
    );

    await tester.tap(find.text('Avis et réputation'));
    await tester.pumpAndSettle();

    expect(find.byType(ReviewsReputationPage), findsOneWidget);
    expect(find.text('Votre crédibilité sur YOKKU'), findsOneWidget);
    expect(find.text('4,8'), findsOneWidget);
    expect(find.text('4,8 ★'), findsOneWidget);
    expect(find.text('32 avis'), findsOneWidget);
    expect(find.text('Qualité des produits'), findsOneWidget);
    expect(find.text('Communication'), findsOneWidget);
    expect(find.text('Marché Central Dakar'), findsOneWidget);
    expect(find.text('Restaurant Teranga'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
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
