import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/app/app_routes.dart';
import 'package:yokku_mbey/features/auth/presentation/pages/login_page.dart';
import 'package:yokku_mbey/features/auth/presentation/pages/verification_page.dart';
import 'package:yokku_mbey/features/auth/presentation/widgets/phone_number_field.dart';

void main() {
  testWidgets('displays the login screen content', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('Bienvenue !'), findsOneWidget);
    expect(find.text('Connectez-vous pour continuer'), findsOneWidget);
    expect(find.byType(PhoneNumberField), findsOneWidget);
    expect(find.text('+221'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
    expect(find.textContaining('Mode démonstration'), findsOneWidget);
    expect(find.textContaining('Aucun SMS réel'), findsOneWidget);
  });

  testWidgets('keeps login content inside narrow phone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.textContaining('Mode démonstration'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(find.byType(GridView), findsNothing);
  });

  testWidgets('opens verification page after tapping continue', (tester) async {
    tester.view.physicalSize = const Size(360, 825);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        routes: AppRoutes.routes,
        initialRoute: LoginPage.routeName,
      ),
    );

    await tester.enterText(find.byType(TextField).first, '77 123 45 67');
    await tester.tap(find.text('Continuer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(VerificationPage), findsOneWidget);
    expect(find.textContaining('Entrez le code'), findsOneWidget);

    await tester.pump(VerificationPage.verificationSuccessDelay);
    await tester.pumpAndSettle();

    expect(find.byType(VerificationPage), findsOneWidget);
  });
}
