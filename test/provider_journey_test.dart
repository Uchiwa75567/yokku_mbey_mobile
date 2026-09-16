import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:yokku_mbey/core/data/marketplace_models.dart';
import 'package:yokku_mbey/core/widgets/service_photo_field.dart';
import 'package:yokku_mbey/features/profile_selection/domain/entities/user_profile_type.dart';
import 'support/marketplace_test_app.dart';
import 'provider_marketplace_test.dart' show publish, login;

void main() {
  Future<void> tap(WidgetTester tester, String label) async {
    await tester.pumpAndSettle();
    final target = find.text(label).last;
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets(
      'gallery imports actual image, clears required validation and removes photo',
      (tester) async {
    phone(tester);
    var photos = <String>[];
    final form = GlobalKey<FormState>();
    final done = Completer<void>();
    ImageSource? source;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Form(
                key: form,
                child: StatefulBuilder(
                    builder: (context, setState) => ServicePhotoField(
                          photos: photos,
                          required: true,
                          pickPhoto: (value) async {
                            source = value;
                            return XFile.fromData(
                                Uint8List.fromList(img
                                    .encodePng(img.Image(width: 4, height: 3))),
                                mimeType: 'image/png',
                                name: 'tractor.png');
                          },
                          onBusyChanged: (busy) {
                            if (!busy && !done.isCompleted) done.complete();
                          },
                          onChanged: (value) => setState(() => photos = value),
                        ))))));
    expect(form.currentState!.validate(), isFalse);
    await tester.pump();
    await tester.runAsync(() async {
      tester
          .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Choisir une photo'))
          .onPressed!();
      for (var i = 0; i < 200 && !done.isCompleted; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(done.isCompleted, isTrue);
    });
    await tester.pumpAndSettle();
    expect(source, ImageSource.gallery);
    expect(photos.single, startsWith('data:image/jpeg'));
    expect(form.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text('Ajoutez une photo de votre matériel.'), findsNothing);
    await tester.tap(find.byTooltip('Supprimer la photo 1'));
    await tester.pumpAndSettle();
    expect(photos, isEmpty);
    expect(form.currentState!.validate(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelling gallery does not add a fake photo', (tester) async {
    final done = Completer<void>();
    var changed = false;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ServicePhotoField(
      photos: const [],
      pickPhoto: (_) async => null,
      onBusyChanged: (busy) {
        if (!busy && !done.isCompleted) done.complete();
      },
      onChanged: (_) => changed = true,
    ))));
    await tester.runAsync(() async {
      tester
          .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Choisir une photo'))
          .onPressed!();
      for (var i = 0; i < 200 && !done.isCompleted; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(done.isCompleted, isTrue);
    });
    await tester.pumpAndSettle();
    expect(changed, isFalse);
    expect(find.text('0 / 3 photos'), findsOneWidget);
  });

  testWidgets(
      'worker form publishes skills and team, then keeps price when editing',
      (tester) async {
    phone(tester);
    final store = testStore(UserProfileType.provider);
    await tester.pumpWidget(marketplaceTestApp(
        store: store,
        route: '/provider-service-form',
        arguments: 'new-workforce'));
    await tester.enterText(
        find.byType(TextFormField).at(0), 'Ouvrier pour le maraîchage');
    await tester.enterText(find.byType(TextFormField).at(1), '6000');
    await tester.enterText(
        find.byType(TextFormField).at(2), 'Récolte et tri, trois campagnes');
    await tester.ensureVisible(find.byTooltip('Agrandir l’équipe'));
    await tester.tap(find.byTooltip('Agrandir l’équipe'));
    await tester.enterText(
        find.byType(TextFormField).at(3), 'Disponible à Thiès pour récolter');
    await tap(tester, 'Publier le service');
    final record = store.records(RecordKind.service).single;
    expect(record.serviceType, ServiceType.workforce);
    expect(record.attributes['teamSize'], '2');
    expect(record.photos, isEmpty);
    await tap(tester, 'Ouvrier pour le maraîchage');
    await tap(tester, 'Modifier mon offre');
    expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).at(1))
            .controller!
            .text,
        '6000');
    await tap(tester, 'Enregistrer les modifications');
    expect(store.records(RecordKind.service), hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'farmer submits request and provider completes the shared mission',
      (tester) async {
    phone(tester);
    final store = testStore(UserProfileType.provider);
    final service = await publish(store);
    login(store, UserProfileType.farmer);
    await tester.pumpWidget(marketplaceTestApp(
        store: store, route: '/farmer-service-detail', arguments: service));
    expect(find.byType(ServicePhoto), findsWidgets);
    await tap(tester, 'Demander cette prestation');
    await tester.enterText(find.byType(TextFormField).at(0), '2');
    await tester.pump();
    expect(find.text('Total estimé : 80 000 FCFA'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(1),
        'Labour du champ accessible près de Thiès');
    await tap(tester, 'Envoyer ma demande');
    final request = store.records(RecordKind.job).single;
    expect(find.text('Accepter la demande'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    login(store, UserProfileType.provider);
    await tester.pumpWidget(marketplaceTestApp(
        store: store, route: '/service-request-detail', arguments: request.id));
    await tap(tester, 'Accepter la demande');
    await tap(tester, 'Démarrer la mission');
    await tap(tester, 'Terminer la mission');
    expect(store.record(request.id)!.status, RecordStatus.completed);
    await tester.pumpWidget(const SizedBox());
    login(store, UserProfileType.farmer);
    await tester.pumpWidget(marketplaceTestApp(
        store: store, route: '/service-request-detail', arguments: request.id));
    expect(find.text('Terminée'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
