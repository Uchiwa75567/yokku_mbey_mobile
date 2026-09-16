import 'package:flutter/material.dart';

import 'app/yokku_mbey_app.dart';
import 'core/data/marketplace_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = MarketplaceStore(persistence: LocalWorkspacePersistence());
  await store.load();
  runApp(YokkuMbeyApp(store: store));
}
