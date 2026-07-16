import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/app/app_routes.dart';
import 'package:yokku_mbey/features/auth/presentation/pages/verification_page.dart';
import 'package:yokku_mbey/features/auth/presentation/widgets/otp_code_boxes.dart';
import 'package:yokku_mbey/features/auth/presentation/widgets/verification_keypad.dart';
import 'package:yokku_mbey/features/profile_selection/presentation/pages/profile_selection_page.dart';

void main() {
  testWidgets('displays the verification screen content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: VerificationPage()),
    );

    expect(find.textContaining('Entrez le code'), findsOneWidget);
    expect(find.textContaining('+221 70 123 45 67'), findsOneWidget);
    expect(find.byType(OtpCodeBoxes), findsOneWidget);
    expect(
        tester.widget<OtpCodeBoxes>(find.byType(OtpCodeBoxes)).code, isEmpty);
    expect(find.text('Renvoyer le code dans 00:45'), findsOneWidget);
    expect(find.byType(VerificationKeypad), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.byType(ListView), findsNothing);
    expect(find.byType(GridView), findsNothing);
  });

  testWidgets('does not open profile selection before four digits are entered',
      (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: AppRoutes.routes,
        initialRoute: VerificationPage.routeName,
      ),
    );

    await tester.pump(VerificationPage.verificationSuccessDelay);
    await tester.pumpAndSettle();

    expect(find.byType(VerificationPage), findsOneWidget);
    expect(find.byType(ProfileSelectionPage), findsNothing);
  });

  testWidgets('opens profile selection after four random digits are entered', (
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
        initialRoute: VerificationPage.routeName,
      ),
    );

    await tester.tap(find.text('1'));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.tap(find.text('4'));
    await tester.pump();

    await tester.pump(VerificationPage.verificationSuccessDelay);
    await tester.pumpAndSettle();

    expect(find.byType(ProfileSelectionPage), findsOneWidget);
    expect(find.text('Vous êtes ?'), findsOneWidget);
  });
}
