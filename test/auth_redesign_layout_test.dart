import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/core/theme/app_theme.dart';
import 'package:yokku_mbey/features/auth/presentation/pages/login_page.dart';
import 'package:yokku_mbey/features/auth/presentation/pages/verification_page.dart';
import 'package:yokku_mbey/features/profile_selection/presentation/pages/profile_selection_page.dart';
import 'package:yokku_mbey/features/splash/presentation/widgets/onboarding_splash_view.dart';
import 'package:yokku_mbey/features/splash/presentation/widgets/splash_background_image.dart';

void main() {
  Future<void> renderImages(WidgetTester tester) async {
    final context = tester.element(find.byType(Scaffold).first);
    final images = tester.widgetList<Image>(find.byType(Image)).toList();
    await tester.runAsync(() async {
      for (final image in images) {
        await precacheImage(image.image, context);
      }
    });
    await tester.pumpAndSettle();
  }

  Future<void> capture(
      WidgetTester tester, GlobalKey boundary, String name) async {
    await tester.runAsync(() async {
      final image = await (boundary.currentContext!.findRenderObject()!
              as RenderRepaintBoundary)
          .toImage();
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('output/qa/auth-$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(data!.buffer.asUint8List());
      image.dispose();
    });
  }

  setUpAll(() async {
    final font = FontLoader('Roboto');
    for (final style in ['regular', 'medium', 'bold', 'black']) {
      font.addFont(rootBundle.load('assets/fonts/roboto-$style.ttf'));
    }
    await font.load();
    final sdk = Platform.environment['FLUTTER_ROOT'];
    if (sdk != null) {
      await (FontLoader('MaterialIcons')
            ..addFont(File(
                    '$sdk/bin/cache/artifacts/material_fonts/materialicons-regular.otf')
                .readAsBytes()
                .then(ByteData.sublistView)))
          .load();
    }
  });
  for (final width in [320.0, 390.0, 1440.0]) {
    testWidgets(
        'light auth pages fit $width and login stays usable with keyboard',
        (tester) async {
      tester.view.physicalSize = Size(width, width > 600 ? 960 : 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      for (final entry in <(String, Widget)>[
        ('splash-original', const Scaffold(body: SplashBackgroundImage())),
        ('onboarding', const Scaffold(body: OnboardingSplashView())),
        ('login', const LoginPage()),
        ('otp', const VerificationPage()),
        ('roles', const ProfileSelectionPage()),
      ]) {
        final boundary = GlobalKey();
        await tester.pumpWidget(RepaintBoundary(
            key: boundary,
            child: MaterialApp(
              key: ValueKey(entry.$1),
              theme: AppTheme.light,
              debugShowCheckedModeBanner: false,
              builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1.25)),
                  child: child!),
              home: entry.$2,
            )));
        await tester.pumpAndSettle();
        await renderImages(tester);
        expect(tester.takeException(), isNull, reason: entry.$1);
        if (width == 390) {
          await capture(tester, boundary, entry.$1);
        }
        if (entry.$1 == 'onboarding') {
          for (var step = 2; step <= 3; step++) {
            await tester.tap(find.text('Suivant'));
            await tester.pumpAndSettle();
            await renderImages(tester);
            expect(tester.takeException(), isNull, reason: 'onboarding $step');
            expect(find.text(step == 3 ? 'Commencer' : 'Suivant').hitTestable(),
                findsOneWidget);
            if (width == 390) {
              await capture(tester, boundary, 'onboarding-$step');
            }
          }
        }
      }
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpWidget(
          MaterialApp(theme: AppTheme.light, home: const LoginPage()));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Continuer'));
      await tester.pumpAndSettle();
      expect(find.text('Continuer').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
