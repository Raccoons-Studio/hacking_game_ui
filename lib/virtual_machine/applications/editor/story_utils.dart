import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:json2yaml/json2yaml.dart';
import 'dart:html' as html;


void saveStoryToYaml(StoryEngine story) {
  try {
    final storyMap = story.toMap();

    final String storyInYaml;
    try {
      storyInYaml = jsonEncode(storyMap);
    } catch (e) {
      print("Error encoding storyMap to JSON: $e");
      print("StoryMap: $storyMap");
      return;
    }

    final yamlEncoded = jsonToYaml(json.decode(storyInYaml));

    if (kIsWeb) {
      final bytes = utf8.encode(yamlEncoded);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(
        href: url,
      );
      anchor.download = '${story.name}.yaml';
      anchor.click();
    } else {
      // handle saving the file in mobile or desktop application
    }
  } catch (e) {
    print("Error: $e");
  }
}

String jsonToYaml(jsonInput) {
  final yamlString = json2yaml(jsonInput);
  return yamlString;
}
