import 'package:flutter/services.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:yaml/yaml.dart';

class SaveAndLoadEngine {
  static Map<String, dynamic> yamlToMap(YamlMap yamlMap) {
    final map = <String, dynamic>{};

    for (var entry in yamlMap.entries) { 
      if (entry.value is YamlMap) {
        map[entry.key] = yamlToMap(entry.value);
      } else if (entry.value is YamlList) {
        map[entry.key] = yamlToList(entry.value);
      } else {
        map[entry.key] = entry.value;
      }
    }

    return map;
  }

  static List<dynamic> yamlToList(YamlList yamlList) {
    final list = <dynamic>[];

    for (var element in yamlList) {
      if (element is YamlMap) {
        list.add(yamlToMap(element));
      } else if (element is YamlList) {
        list.add(yamlToList(element));
      } else {
        list.add(element);
      }
    }

    return list;
  }

  static Future<StoryEngine> loadStoryEngine(String path) async {
    final storyEngineYaml = await rootBundle.loadString("assets/" + path);
    final storyEngineMap = yamlToMap(loadYaml(storyEngineYaml) as YamlMap);
    return StoryEngine.fromMap(storyEngineMap);
  }
}
