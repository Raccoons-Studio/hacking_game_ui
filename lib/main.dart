import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hacking_game_ui/game_menu.dart';
import 'package:hacking_game_ui/maestro/maestro_story.dart';
import 'package:hacking_game_ui/utils/analytics.dart';
import 'package:hacking_game_ui/virtual_machine/virtual_desktop.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> _configureMacosWindowUtils() async {
  const config = MacosWindowUtilsConfig();
  await config.apply();
}

Future<void> main() async {
  if (!kIsWeb) {
    if (Platform.isMacOS) {
      await _configureMacosWindowUtils();
    }
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AnalyticsService().logOpenApp();
    return MacosApp(
      title: 'macos_ui Widget Gallery',
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: kDebugMode ? MacOSDesktop(maestro: MaestroStory()) : GameMenu()
    );
  }
}
