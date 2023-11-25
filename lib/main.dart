import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:hacking_game_ui/game_menu.dart';
import 'package:hacking_game_ui/utils/analytics.dart';
import 'package:macos_ui/macos_ui.dart';

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
      home: GameMenu(),
      localizationsDelegates: [
        FlutterI18nDelegate(
          translationLoader: FileTranslationLoader(
            useCountryCode: false,
            fallbackFile: 'en',
            basePath: 'i18n',
            //forcedLocale: Locale('es'),
          ),
          missingTranslationHandler: (key, locale) {
            print(
                "--- Missing Key: $key, languageCode: ${locale?.languageCode ?? ''}");
          },
        ),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
    );
  }
}
