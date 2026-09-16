import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/core/theme/app_theme.dart';
import 'package:yokku_mbey/core/widgets/auth_scaffold.dart';
import 'package:yokku_mbey/core/widgets/journey_scaffold.dart';
import 'package:yokku_mbey/features/profile_selection/domain/entities/user_profile_type.dart';
import 'support/marketplace_test_app.dart';

void main() {
  void viewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  for (final size in [
    const Size(320, 844),
    const Size(553, 912),
    const Size(1440, 1000),
  ]) {
    testWidgets('short routed pages start at the top at $size', (tester) async {
      viewport(tester, size);
      for (final page in [
        (UserProfileType.farmer, '/harvest-edit'),
        (UserProfileType.farmer, '/settings'),
        (UserProfileType.buyer, '/buyer-address-form'),
        (UserProfileType.provider, '/provider-contacts'),
        (UserProfileType.investor, '/investor-impact'),
      ]) {
        await tester.pumpWidget(
            marketplaceTestApp(store: testStore(page.$1), route: page.$2));
        await tester.pumpAndSettle();
        // A wrapped title can make the row taller than its centered icon.
        final header = find.ancestor(
            of: find.widgetWithIcon(IconButton, Icons.arrow_back),
            matching: find.byType(Row));
        expect(tester.getTopLeft(header.first).dy, 12, reason: page.$2);
        expect(tester.takeException(), isNull, reason: page.$2);
      }
    });
  }

  testWidgets(
      'top alignment respects safe areas, width and fixed bottom actions',
      (tester) async {
    viewport(tester, const Size(1200, 1000));
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 20);
    tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 20);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: JourneyScaffold(
            title: 'Page courte',
            bottom: JourneyButton(label: 'Enregistrer', onPressed: () async {}),
            children: const [Text('Contenu')])));
    await tester.pumpAndSettle();
    expect(
        tester.getTopLeft(find.widgetWithIcon(IconButton, Icons.arrow_back)).dy,
        36);
    expect(tester.getTopLeft(find.text('Contenu')).dx, 260);
    expect(
        tester
            .getBottomLeft(find.widgetWithText(FilledButton, 'Enregistrer'))
            .dy,
        968);
    expect(tester.takeException(), isNull);
  });

  testWidgets('short root screens stay at the top and retain bottom navigation',
      (tester) async {
    viewport(tester, const Size(553, 912));
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const JourneyScaffold(
            title: 'Mes offres',
            root: true,
            profileType: UserProfileType.provider,
            children: [Text('Aucune offre')])));
    await tester.pumpAndSettle();
    expect(
        tester
            .getTopLeft(find
                .ancestor(
                    of: find.widgetWithIcon(
                        IconButton, Icons.notifications_none_outlined),
                    matching: find.byType(Row))
                .first)
            .dy,
        12);
    expect(tester.getTopLeft(find.text('Accueil')).dy, greaterThan(800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('long content remains scrollable with keyboard open',
      (tester) async {
    viewport(tester, const Size(553, 912));
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: JourneyScaffold(title: 'Formulaire', children: [
          const SizedBox(height: 900),
          JourneyButton(label: 'Enregistrer', onPressed: () async {}),
        ])));
    await tester.pumpAndSettle();
    expect(
        tester.getTopLeft(find.widgetWithIcon(IconButton, Icons.arrow_back)).dy,
        12);
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Enregistrer').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('authentication header also starts below the top safe area',
      (tester) async {
    viewport(tester, const Size(553, 912));
    tester.view.padding = const FakeViewPadding(top: 24);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home:
            const AuthScaffold(back: true, children: [Text('Verification')])));
    await tester.pumpAndSettle();
    expect(
        tester.getTopLeft(find.widgetWithIcon(IconButton, Icons.arrow_back)).dy,
        40);
    expect(tester.takeException(), isNull);
  });
}
