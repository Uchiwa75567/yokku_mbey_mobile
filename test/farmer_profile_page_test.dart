import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/app/app_routes.dart';
import 'package:yokku_mbey/features/home/presentation/pages/profile_home_page.dart';
import 'package:yokku_mbey/features/profile/presentation/pages/farmer_profile_page.dart';
import 'package:yokku_mbey/features/profile_selection/domain/entities/user_profile_type.dart';

void main() {
  testWidgets('opens the farmer profile from the bottom navigation', (
    tester,
  ) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          FarmerProfilePage.routeName: (_) => const FarmerProfilePage(),
        },
        home: const ProfileHomePage(profileType: UserProfileType.farmer),
      ),
    );

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.byType(FarmerProfilePage), findsOneWidget);
    expect(find.text('Ibrahima Mbaye'), findsOneWidget);
    expect(find.text('Agriculteur vérifié • Kaolack'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('4,8'), findsOneWidget);
    expect(find.text('95%'), findsOneWidget);
    expect(find.text('Mes récoltes'), findsOneWidget);
    expect(find.text('Aide et support'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens farmer harvests from the profile menu', (tester) async {
    _setPhoneViewport(tester);

    await tester.pumpWidget(
      MaterialApp(
        routes: AppRoutes.routes,
        initialRoute: FarmerProfilePage.routeName,
      ),
    );

    await tester.tap(find.text('Mes récoltes'));
    await tester.pumpAndSettle();

    expect(find.text('Mes récoltes'), findsOneWidget);
    expect(find.text('Gérez toutes vos annonces'), findsOneWidget);
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
