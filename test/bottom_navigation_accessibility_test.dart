import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/features/home/presentation/widgets/farmer_bottom_navigation.dart';

void main() {
  testWidgets('central action semantics stay inside the visible button',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      var destination = '';
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          bottomNavigationBar: FarmerBottomNavigation(
            activeTab: FarmerNavigationTab.home,
            secondLabel: 'Recherche',
            actionLabel: 'Publier une demande',
            onPublishHarvest: () => destination = 'publish',
            onHarvests: () => destination = 'search',
            onProfile: () => destination = 'profile',
          ),
        ),
      ));

      final action = find.bySemanticsLabel('Publier une demande');
      expect(tester.getSemantics(action).rect.size, const Size(48, 48));
      await tester.tap(find.text('Recherche'));
      expect(destination, 'search');
      await tester.tap(find.text('Profil'));
      expect(destination, 'profile');
      await tester.tap(action);
      expect(destination, 'publish');
    } finally {
      semantics.dispose();
    }
  });
}
