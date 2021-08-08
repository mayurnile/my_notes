import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import './core/core.dart';
import './core/di/locator.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  di.init();
  runApp(MyNotes());
}

class MyNotes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My Notes',
      theme: MyNotesTheme.getMyNotesThemeData(),
      debugShowCheckedModeBanner: false,
      navigatorKey: di.locator<NavigationService>().navigatorKey,
      onGenerateRoute: generateRoute,
    );
  }
}
