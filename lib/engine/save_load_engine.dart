import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/engine/player_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';

class Savegame {
  String id;
  DateTime date;
  String name;
  int week;
  int day;
  int hour;
  Player player;
  bool isLocal;

  Savegame(this.id, this.date, this.name, this.week, this.day, this.hour, this.player, this.isLocal);

  Savegame.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        date = DateTime.parse(json['date']),
        name = json['name'],
        week = json['week'],
        day = json['day'],
        hour = json['hour'],
        isLocal = json['isLocal']??false,
        player = Player.fromJson(Map<String, dynamic>.from(json['player']));

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'name': name,
        'week': week,
        'day': day,
        'hour': hour,
        'player': player.toJson(),
        'isLocal': isLocal,
      };
}

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
    final storyEngineYaml = await rootBundle.loadString("$path");
    try {
      var yml = loadYaml(storyEngineYaml);
      final storyEngineMap = yamlToMap(yml as YamlMap);
      return StoryEngine.fromMap(storyEngineMap);
    } catch (e) {
      print(e);
    }
    return StoryEngine("", "", "", [], [], [], [], [], [], [], []);
  }
}
