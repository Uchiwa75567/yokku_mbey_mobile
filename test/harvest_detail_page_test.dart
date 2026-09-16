import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/app/app_routes.dart';
import 'package:yokku_mbey/features/harvest_detail/presentation/pages/harvest_detail_page.dart';
import 'package:yokku_mbey/features/harvest_publication/presentation/pages/harvest_publication_page.dart';

void main() {
  testWidgets('shows the published harvest detail after the final step', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 825);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        routes: AppRoutes.routes,
        initialRoute: HarvestPublicationPage.routeName,
      ),
    );

    await tester.ensureVisible(find.text('Continuer'));
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continuer'));
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Publier la récolte'));
    await tester.tap(find.text('Publier la récolte'));
    await tester.pumpAndSettle();

    expect(find.byType(HarvestDetailPage), findsOneWidget);
    expect(find.text('Tomate fraîche'), findsOneWidget);
    expect(find.text('400 FCFA / kg'), findsOneWidget);
    expect(find.text('500 kg disponibles · Kaolack'), findsOneWidget);
    expect(find.text('Informations'), findsOneWidget);
    expect(find.text('Modifier'), findsOneWidget);
    expect(find.text('Booster'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
