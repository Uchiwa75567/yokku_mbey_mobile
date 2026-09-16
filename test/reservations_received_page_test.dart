import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/app/app_routes.dart';
import 'package:yokku_mbey/features/home/presentation/pages/profile_home_page.dart';
import 'package:yokku_mbey/features/profile_selection/domain/entities/user_profile_type.dart';
import 'package:yokku_mbey/features/reservations/presentation/pages/reservation_detail_page.dart';
import 'package:yokku_mbey/features/reservations/presentation/pages/reservations_received_page.dart';

void main() {
  testWidgets('opens received reservations from the farmer navigation', (
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
        routes: {
          ReservationsReceivedPage.routeName: (_) =>
              const ReservationsReceivedPage(),
        },
        home: const ProfileHomePage(profileType: UserProfileType.farmer),
      ),
    );

    await tester.tap(find.text('Réservations').last);
    await tester.pumpAndSettle();

    expect(find.byType(ReservationsReceivedPage), findsOneWidget);
    expect(find.text('Réservations reçues'), findsOneWidget);
    expect(find.text('Marché Central Dakar'), findsOneWidget);
    expect(find.text('Sokhna Distribution'), findsOneWidget);
    expect(find.text('Restaurant Teranga'), findsOneWidget);
    expect(find.text('Voir la demande'), findsNWidgets(3));
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filters accepted and completed reservations', (tester) async {
    tester.view.physicalSize = const Size(360, 825);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        routes: AppRoutes.routes,
        initialRoute: ReservationsReceivedPage.routeName,
      ),
    );

    await tester.tap(find.text('Acceptées'));
    await tester.pump();

    expect(find.text('Sokhna Distribution'), findsOneWidget);
    expect(find.text('Marché Central Dakar'), findsNothing);

    await tester.tap(find.text('Terminées'));
    await tester.pump();

    expect(
      find.text('Aucune réservation'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens a reservation detail and accepts the request', (
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
        initialRoute: ReservationsReceivedPage.routeName,
      ),
    );

    await tester.tap(find.text('Voir la demande').first);
    await tester.pumpAndSettle();

    expect(find.byType(ReservationDetailPage), findsOneWidget);
    expect(find.text('Détail de la réservation'), findsOneWidget);
    expect(find.text('Marché Central Dakar'), findsOneWidget);
    expect(find.text('80000 FCFA'), findsOneWidget);

    await tester.ensureVisible(find.text('Accepter la réservation'));
    await tester.tap(find.text('Accepter la réservation'));
    await tester.pump();

    expect(find.text('Réservation acceptée'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
