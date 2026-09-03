import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yokku_mbey/features/buyer_products/presentation/pages/buyer_products_page.dart';
import 'package:yokku_mbey/features/buyer_products/presentation/pages/buyer_product_detail_page.dart';
import 'package:yokku_mbey/features/buyer_products/presentation/pages/pre_reservation_page.dart';
import 'package:yokku_mbey/features/buyer_products/presentation/pages/product_reservation_page.dart';
import 'package:yokku_mbey/features/buyer_products/presentation/pages/buyer_payment_page.dart';
import 'package:yokku_mbey/features/home/presentation/pages/buyer_home_page.dart';

void main() {
  testWidgets('opens all buyer products from the home page', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          BuyerProductsPage.routeName: (_) => const BuyerProductsPage(),
          BuyerProductDetailPage.routeName: BuyerProductDetailPage.fromRoute,
          PreReservationPage.routeName: PreReservationPage.fromRoute,
          ProductReservationPage.routeName: ProductReservationPage.fromRoute,
          BuyerPaymentPage.routeName: BuyerPaymentPage.fromRoute,
        },
        home: const BuyerHomePage(),
      ),
    );

    await tester.tap(find.text('Voir tout').first);
    await tester.pumpAndSettle();

    expect(find.byType(BuyerProductsPage), findsOneWidget);
    expect(find.text('Trouvez des produits disponibles'), findsOneWidget);
    expect(find.text('24 résultats'), findsOneWidget);
    expect(find.text('Tomate fraîche'), findsOneWidget);
    expect(find.text('4.6'), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('changes the quick product filter', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(home: BuyerProductsPage()),
    );

    await tester.tap(find.text('Kaolack').first);
    await tester.pump();

    expect(find.text('Kaolack'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens the buyer product detail', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        routes: {
          BuyerProductDetailPage.routeName: BuyerProductDetailPage.fromRoute,
          PreReservationPage.routeName: PreReservationPage.fromRoute,
          ProductReservationPage.routeName: ProductReservationPage.fromRoute,
          BuyerPaymentPage.routeName: BuyerPaymentPage.fromRoute,
        },
        home: BuyerProductsPage(),
      ),
    );

    await tester.tap(find.text('Tomate fraîche'));
    await tester.pumpAndSettle();

    expect(find.byType(BuyerProductDetailPage), findsOneWidget);
    expect(find.text('400 FCFA / kg'), findsOneWidget);
    expect(find.text('Ibrahima NDIAYE'), findsOneWidget);
    expect(find.text('Réserver ce produit'), findsOneWidget);
    expect(find.text('Appeler ou WhatsApp'), findsOneWidget);

    await tester.ensureVisible(find.text('Réserver ce produit'));
    await tester.tap(find.text('Réserver ce produit'));
    await tester.pumpAndSettle();

    expect(find.byType(ProductReservationPage), findsOneWidget);
    expect(find.text('80 000 FCFA'), findsOneWidget);
    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, -260),
    );
    await tester.pumpAndSettle();
    expect(find.text('Payer maintenant'), findsOneWidget);
    expect(find.text('Payer un acompte'), findsOneWidget);
    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    expect(find.byType(BuyerPaymentPage), findsOneWidget);
    expect(find.text('Tomate fraîche • 200 kg'), findsOneWidget);
    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(find.text('Payer 80 000 FCFA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pre-reserves an upcoming potato harvest', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        routes: {
          BuyerProductDetailPage.routeName: BuyerProductDetailPage.fromRoute,
          PreReservationPage.routeName: PreReservationPage.fromRoute,
          ProductReservationPage.routeName: ProductReservationPage.fromRoute,
          BuyerPaymentPage.routeName: BuyerPaymentPage.fromRoute,
        },
        home: BuyerProductsPage(),
      ),
    );

    await tester.tap(find.text('Pomme de terre'));
    await tester.pumpAndSettle();

    expect(find.text('Pré-réserver ce produit'), findsOneWidget);
    await tester.ensureVisible(find.text('Pré-réserver ce produit'));
    await tester.tap(find.text('Pré-réserver ce produit'));
    await tester.pumpAndSettle();

    expect(find.byType(PreReservationPage), findsOneWidget);
    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, -220),
    );
    await tester.pumpAndSettle();
    expect(find.text('100 000 FCFA'), findsOneWidget);
    expect(find.text('20 000 FCFA'), findsOneWidget);
    await tester.drag(
      find.byType(CustomScrollView),
      const Offset(0, -450),
    );
    await tester.pumpAndSettle();
    expect(find.text('Continuer vers le paiement'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
