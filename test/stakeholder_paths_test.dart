import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/marketplace_test_app.dart';
import 'package:yokku_mbey/features/profile_selection/domain/entities/user_profile_type.dart';
import 'package:yokku_mbey/features/stakeholders/presentation/pages/stakeholder_pages.dart';

void main() {
  testWidgets('opens the provider service path from its home', (tester) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      marketplaceTestApp(store: testStore(UserProfileType.provider)),
    );

    await tester.tap(find.text('Ajouter un service'));
    await tester.pumpAndSettle();

    expect(find.byType(ProviderServiceFormPage), findsOneWidget);
    expect(find.text('Publier le service'), findsOneWidget);
  });

  testWidgets('opens the investor projects path from its home', (tester) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      marketplaceTestApp(store: testStore(UserProfileType.investor)),
    );

    await tester.tap(find.text('Voir les projets'));
    await tester.pumpAndSettle();

    expect(find.byType(InvestorProjectsPage), findsOneWidget);
    expect(find.text('Projets agricoles'), findsOneWidget);
  });
}

void _setPhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
