import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/app/app_routes.dart';
import 'package:yokku_mbey/features/harvests/presentation/pages/farmer_harvests_page.dart';
import 'package:yokku_mbey/features/stock_management/presentation/pages/stock_management_page.dart';

void main() {
  testWidgets('opens stock management from the harvest actions menu', (
    tester,
  ) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        routes: AppRoutes.routes,
        initialRoute: FarmerHarvestsPage.routeName,
      ),
    );

    await tester.tap(find.byIcon(Icons.more_horiz).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gérer le stock'));
    await tester.pumpAndSettle();

    expect(find.byType(StockManagementPage), findsOneWidget);
    expect(find.text('Gestion du stock'), findsOneWidget);
    expect(find.text('Tomate fraîche'), findsOneWidget);
    expect(find.text('1 000 kg'), findsOneWidget);
    expect(find.text('300 kg'), findsNWidgets(2));
    expect(find.text('Disponible'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('updates the remaining stock and marks it as sold out', (
    tester,
  ) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      const MaterialApp(
        home: StockManagementPage(stock: StockManagementPage.defaultStock),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('stock-quantity-field')),
      '250',
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('update-stock-button')));
    await tester.pump();

    expect(find.text('250 kg'), findsOneWidget);
    expect(find.text('Stock mis à jour'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('mark-sold-out-button')));
    await tester.pump();

    expect(find.text('0 kg'), findsOneWidget);
    expect(find.text('Épuisée'), findsOneWidget);
    expect(find.text('La récolte est maintenant épuisée'), findsOneWidget);
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
