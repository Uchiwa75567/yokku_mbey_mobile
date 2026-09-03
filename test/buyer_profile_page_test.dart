import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/features/buyer_needs/presentation/pages/buyer_needs_page.dart';
import 'package:yokku_mbey/features/buyer_profile/presentation/pages/buyer_delivery_addresses_page.dart';
import 'package:yokku_mbey/features/buyer_profile/presentation/pages/buyer_address_form_page.dart';
import 'package:yokku_mbey/features/buyer_profile/presentation/pages/buyer_profile_page.dart';
import 'package:yokku_mbey/features/home/presentation/pages/buyer_home_page.dart';

void main() {
  testWidgets('opens buyer profile from the buyer navigation', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          BuyerProfilePage.routeName: (_) => const BuyerProfilePage(),
        },
        home: const BuyerHomePage(),
      ),
    );

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.byType(BuyerProfilePage), findsOneWidget);
    expect(find.text('Awa DIOP'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('Mes achats'), findsOneWidget);
    expect(find.text('Favoris et alertes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens buyer needs from profile', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          BuyerNeedsPage.routeName: (_) => const BuyerNeedsPage(),
        },
        home: const BuyerProfilePage(),
      ),
    );

    await tester.tap(find.text('Mes demandes'));
    await tester.pumpAndSettle();

    expect(find.byType(BuyerNeedsPage), findsOneWidget);
  });

  testWidgets('adds a delivery address', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        routes: {
          BuyerAddressFormPage.routeName: BuyerAddressFormPage.fromRoute,
        },
        home: BuyerDeliveryAddressesPage(),
      ),
    );

    expect(find.text('Boutique principale'), findsOneWidget);
    await tester.tap(find.text('Ajouter une adresse'));
    await tester.pumpAndSettle();

    const values = [
      'Point de vente',
      'Dakar',
      'Dakar',
      'Ouakam',
      'Route de la Corniche',
      '70 000 00 00',
    ];
    for (var index = 0; index < values.length; index++) {
      await tester.enterText(
          find.byType(TextFormField).at(index), values[index]);
    }
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text("Enregistrer l'adresse"));
    await tester.pumpAndSettle();

    expect(find.byType(BuyerDeliveryAddressesPage), findsOneWidget);
    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();
    expect(find.text('Point de vente'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
