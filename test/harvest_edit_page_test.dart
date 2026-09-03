import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/app/app_routes.dart';
import 'package:yokku_mbey/features/harvest_edit/presentation/pages/harvest_edit_page.dart';
import 'package:yokku_mbey/features/harvests/presentation/pages/farmer_harvests_page.dart';

void main() {
  testWidgets('opens the selected harvest in the edit form', (tester) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        routes: AppRoutes.routes,
        initialRoute: FarmerHarvestsPage.routeName,
      ),
    );

    await tester.tap(find.text('Modifier').first);
    await tester.pumpAndSettle();

    expect(find.byType(HarvestEditPage), findsOneWidget);
    expect(find.text('Modifier la récolte'), findsOneWidget);
    expect(find.text('18 réservations déjà reçues'), findsOneWidget);
    expect(find.text('Tomate fraîche'), findsNWidgets(2));
    expect(find.text('400 FCFA/kg'), findsOneWidget);
    expect(find.text('300 kg'), findsOneWidget);
    expect(find.text('50 kg'), findsOneWidget);
    expect(find.text('Disponible maintenant'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('updates editable values and confirms the save', (tester) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      const MaterialApp(
        home: HarvestEditPage(harvest: HarvestEditPage.defaultHarvest),
      ),
    );

    await _enterField(tester, 'harvest-price-field', '450');
    await _enterField(tester, 'harvest-quantity-field', '250');
    await _enterField(tester, 'harvest-minimum-field', '25');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enregistrer les modifications'));
    await tester.pump();

    expect(find.text('Modifications enregistrées'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _enterField(
  WidgetTester tester,
  String fieldKey,
  String value,
) async {
  final field = find.descendant(
    of: find.byKey(ValueKey(fieldKey)),
    matching: find.byType(TextFormField),
  );
  await tester.enterText(field, value);
  await tester.pump();
}

void _setPhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 825);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
