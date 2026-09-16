import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/core/widgets/journey_scaffold.dart';
import 'package:yokku_mbey/features/profile_selection/domain/entities/user_profile_type.dart';
import 'support/marketplace_test_app.dart';

void main() {
  setUpAll(() async {
    final sdk = Platform.environment['FLUTTER_ROOT'];
    if (sdk == null) {
      return;
    }
    final roboto = FontLoader('Roboto');
    for (final style in ['regular', 'bold', 'medium', 'black']) {
      roboto.addFont(
          File('$sdk/bin/cache/artifacts/material_fonts/roboto-$style.ttf')
              .readAsBytes()
              .then((b) => ByteData.sublistView(b)));
    }
    await roboto.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(File(
              '$sdk/bin/cache/artifacts/material_fonts/materialicons-regular.otf')
          .readAsBytes()
          .then((b) => ByteData.sublistView(b)));
    await icons.load();
  });
  for (final width in [320.0, 390.0, 1440.0]) {
    testWidgets('live journey screens fit width $width with enlarged text',
        (tester) async {
      tester.view.physicalSize = Size(width, width > 600 ? 960 : 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final layoutErrors = <String>[];
      for (final role in [
        UserProfileType.farmer,
        UserProfileType.buyer,
        UserProfileType.investor,
        UserProfileType.provider
      ]) {
        final store = testStore(role);
        final routes = <(String, Object?)>[
          ('/home', null),
          if (role == UserProfileType.buyer) ...[
            ('/buyer-products', null),
            ('/buyer-product-detail', 'tomato'),
            ('/product-reservation', 'tomato'),
            ('/buyer-purchases', null),
            ('/publish-buyer-need', null),
            ('/buyer-profile', null),
            ('/buyer-address-form', null),
            ('/buyer-create-alert', null),
          ] else if (role == UserProfileType.investor) ...[
            ('/investor-projects', null),
            ('/investor-project-detail', 'irrigation'),
            ('/investor-commitment', 'irrigation'),
            ('/investor-funding', null),
            ('/investor-impact', null),
            ('/account-profile', null),
          ] else if (role == UserProfileType.provider) ...[
            ('/provider-services', null),
            ('/provider-service-form', null),
            ('/provider-service-form', 'new-workforce'),
            ('/provider-directory', null),
            ('/provider-service-detail', 'demo-tractor'),
            ('/provider-requests', null),
            ('/provider-request-detail', 'transport'),
            ('/provider-quote', 'transport'),
            ('/provider-jobs', null),
            ('/account-profile', null),
          ] else ...[
            ('/farmer-services', null),
            ('/farmer-service-detail', 'demo-tractor'),
            ('/farmer-service-detail', 'demo-worker'),
            ('/farmer-service-requests', null),
            ('/farmer-harvests', null),
            ('/harvest-detail', null),
            ('/publish-harvest', null),
            ('/harvest-edit', null),
            ('/harvest-boost', null),
            ('/reservations-received', null),
            ('/reservation-detail', null),
            ('/stock-management', null),
            ('/farmer-profile', null),
            ('/reviews-reputation', null),
            ('/payments-withdrawals', null),
            ('/my-needs', null),
            ('/wanted-products', null),
            ('/opportunities', null),
            ('/my-farm', null),
            ('/settings', null),
            ('/help-support', null),
            ('/notifications', null),
            ('/farmer-product-response', null),
            ('/seed-search', null),
          ],
        ];
        if (role == UserProfileType.buyer) {
          final order = await store.reserve(
              productId: 'tomato', quantity: 100, recovery: 'Retrait');
          routes.add(('/buyer-order-tracking', order.id));
        }
        for (final entry in routes) {
          final boundary = GlobalKey();
          await tester.pumpWidget(RepaintBoundary(
              key: boundary,
              child: marketplaceTestApp(
                  store: store,
                  route: entry.$1,
                  arguments: entry.$2,
                  textScale: 1.25)));
          await tester.pumpAndSettle();
          final journey = find.byType(JourneyScaffold);
          if (journey.evaluate().isNotEmpty) {
            final viewport = find
                .descendant(
                    of: journey, matching: find.byType(SingleChildScrollView))
                .first;
            expect(tester.getTopLeft(viewport).dy, 0,
                reason: '${role.name} ${entry.$1} must start at the top');
          }
          final initialError = tester.takeException();
          if (initialError != null) {
            layoutErrors.add('${role.name} ${entry.$1}: $initialError');
          }
          if (width == 390) {
            await tester.runAsync(() async {
              final render = boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
              final image = await render.toImage(pixelRatio: 1);
              final bytes =
                  await image.toByteData(format: ui.ImageByteFormat.png);
              final file = File(
                  'output/qa/${role.name}${entry.$1.replaceAll('/', '-')}.png');
              await file.parent.create(recursive: true);
              await file.writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
          final scrollables = find.byType(Scrollable);
          if (scrollables.evaluate().isNotEmpty) {
            await tester.drag(scrollables.first, const Offset(0, -650));
          }
          await tester.pumpAndSettle();
          final scrollError = tester.takeException();
          if (scrollError != null) {
            layoutErrors.add('Scrolled ${entry.$1}: $scrollError');
          }
        }
      }
      expect(layoutErrors, isEmpty);
    });
  }
}
