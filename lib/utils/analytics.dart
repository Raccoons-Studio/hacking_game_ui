import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();

  factory AnalyticsService() {
    return _instance;
  }

  AnalyticsService._internal();

  void logOpenApp() async {
    try {
      await FirebaseAnalytics.instance.logAppOpen();
    } catch (e) {
      print(e);
    }
  }

  void logOpenVirtualApp(String name) async {
    try {
      await FirebaseAnalytics.instance.logEvent(name: 'open_virtual_app', parameters: {name: name});
    } catch (e) {
      print(e);
    }
  }

  void logPlayCinematic(String name) async {
    try {
      await FirebaseAnalytics.instance.logEvent(name: 'play_cinematic', parameters: {name: name});
    } catch (e) {
      print(e);
    }
  }

  void logPlayConversation(String name) async {
    try {
      await FirebaseAnalytics.instance.logEvent(name: 'play_conversation', parameters: {name: name});
    } catch (e) {
      print(e);
    }
  }

  void logNext(String name) async {
    try {
      await FirebaseAnalytics.instance.logEvent(name: 'next', parameters: {name: name});
    } catch (e) {
      print(e);
    }
  }

  void logEvent(String eventName, String? value, String? subvalue) async {
    try {
      await FirebaseAnalytics.instance.logEvent(name: eventName, parameters: {
        'value': value,
        'subvalue': subvalue,
      });
    } catch (e) {
      print(e);
    }
  }

  void logScreen(String screenName, String screenClass) async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'screen_view',
        parameters: {
          'firebase_screen': screenName,
          'firebase_screen_class': screenClass,
        },
      );
    } catch (e) {
      print(e);
    }
  }
}
