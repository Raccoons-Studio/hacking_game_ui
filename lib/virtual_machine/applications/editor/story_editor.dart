import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'dart:html' as html;
import 'package:json2yaml/json2yaml.dart';

class StoryEditor extends StatefulWidget {
  final StoryEngine story;
  StoryEditor({required this.story});

  @override
  _StoryEditorState createState() => _StoryEditorState();
}

class _StoryEditorState extends State<StoryEditor> {
  EvidenceType dropdownValue = EvidenceType.position;
  CharacterEngine? selectedCharacter;
  int selectedWeek = 0;
  int selectedDay = 1;
  List<CharacterEngine> characters = [];
  List<ElementEngine> filteredElements = [];
  List<int> weeks = List<int>.generate(10, (index) => index);
  List<int> days = List<int>.generate(7, (index) => index + 1);

  Future<void> getAllCharacters() async {
    characters = await widget.story.characters;
    if (characters.isNotEmpty) selectedCharacter = characters[0];
    setState(() {});
  }

  void filterElements() {
    filteredElements = widget.story.elements.where((element) {
      return element.characterID == selectedCharacter?.ID &&
          element.week == selectedWeek &&
          element.day == selectedDay;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    getAllCharacters();
    filterElements();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          buildFilters(),
          Expanded(
            child: buildElementList(),
          ),
          ElevatedButton(
            child: Text('Add'),
            onPressed: () {
              setState(() {
                final newElement = ElementEngine(
                  "WEEK-$selectedWeek-$selectedDay-0-${selectedCharacter?.ID}-position",
                  "",
                  selectedCharacter!.ID,
                  EvidenceType.position,
                  false,
                  selectedWeek,
                  selectedDay,
                  7,
                );
                widget.story.elements.add(newElement);
                filterElements();
              });
            },
          ),
        ],
      ),
    );
  }

  SingleChildScrollView buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          DropdownButton<int>(
            value: selectedWeek,
            items: weeks.map((week) {
              return DropdownMenuItem(
                value: week,
                child: Text(week.toString()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedWeek = value ?? 1;
              });
            },
          ),
          DropdownButton<int>(
            value: selectedDay,
            items: days.map((day) {
              return DropdownMenuItem(
                value: day,
                child: Text(day.toString()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedDay = value ?? 1;
              });
            },
          ),
          DropdownButton<CharacterEngine>(
            value: selectedCharacter,
            items: characters.map((character) {
              return DropdownMenuItem(
                value: character,
                child: Text(character.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCharacter = value ?? null;
              });
            },
          ),
          ElevatedButton(
            child: Text('Filter'),
            onPressed: () {
              setState(() {
                filterElements();
              });
            },
          ),
          ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                saveStoryToYaml();
              }),
        ],
      ),
    );
  }

  void saveStoryToYaml() {
    final storyMap = widget.story.toMap();
    final storyInYaml = jsonEncode(storyMap);
    final yamlEncoded = jsonToYaml(json.decode(storyInYaml));

    if (kIsWeb) {
      final bytes = utf8.encode(yamlEncoded);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(
        href: url,
      );
      anchor.download = '${widget.story.name}.yaml';
      anchor.click();
    } else {
      // handle saving the file in mobile or desktop application
    }
  }

  String jsonToYaml(jsonInput) {
    final yamlString = json2yaml(jsonInput);
    return yamlString;
  }

  Widget buildElementList() {
    return ListView.builder(
      itemCount: filteredElements.length,
      itemBuilder: (context, index) {
        ElementEngine element = filteredElements[index];
        List<int> hours = [7, 10, 13, 16, 19, 22];
        List<int> nsfwLevels = [0, 1, 2];
        return Row(
          children: [
            DropdownButton<int>(
              value: element.hour,
              items: hours.map((int hour) {
                return DropdownMenuItem<int>(
                  value: hour,
                  child: Text(hour.toString()),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  if (newValue != null) {
                    element.hour = newValue;
                    element.ID =
                        "WEEK-${element.week}-${element.day}-${element.hour}-${element.characterID}-${element.type.name}";
                  }
                });
              },
            ),
            DropdownButton<EvidenceType>(
              value: element.type,
              onChanged: (EvidenceType? newValue) {
                setState(() {
                  if (newValue != null) {
                    element.type = newValue;
                    element.ID =
                        "WEEK-${element.week}-${element.day}-${element.hour}-${element.characterID}-${element.type.name}";
                  }
                });
              },
              items: <EvidenceType>[
                EvidenceType.position,
                EvidenceType.rearCamera,
                EvidenceType.heartbeat
              ].map<DropdownMenuItem<EvidenceType>>((EvidenceType value) {
                return DropdownMenuItem<EvidenceType>(
                  value: value,
                  child: Text(value.name),
                );
              }).toList(),
            ),
            Checkbox(
                value: element.isEvidence,
                onChanged: (bool? value) {
                  if (value != null) {
                    setState(() {
                      element.isEvidence = value;
                      element.ID =
                          "WEEK-${element.week}-${element.day}-${element.hour}-${element.characterID}-${element.type.name}";
                    });
                  }
                }),
            DropdownButton<String>(
              items: ['Case1', 'Case2', 'Case3'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {},
            ),
            DropdownButton<int>(
              value: element.nsfwLevel,
              items: nsfwLevels.map((int level) {
                return DropdownMenuItem<int>(
                  value: level,
                  child: Text(level.toString()),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  if (newValue != null) {
                    element.nsfwLevel = newValue;
                  }
                });
              },
            ),
            Expanded(
              child: Container(
                width: 200,
                child: TextField(
                  controller: TextEditingController(text: element.description),
                  decoration: InputDecoration(hintText: "Description"),
                  onChanged: (value) {
                    element.description = value;
                  },
                ),
              ),
            ),
            if (element.type == EvidenceType.position)
              Container(
                width: 200,
                child: DropdownButton<PlaceEngine>(
                  value: element.placeID == null
                      ? null
                      : widget.story.places
                          .firstWhere((place) => place.ID == element.placeID),
                  items: widget.story.places.map((PlaceEngine place) {
                    return DropdownMenuItem<PlaceEngine>(
                      value: place,
                      child: Text(place.name),
                    );
                  }).toList(),
                  onChanged: (PlaceEngine? newValue) {
                    setState(() {
                      if (newValue != null) {
                        element.placeID = newValue.ID;
                      }
                    });
                  },
                ),
              ),
            if (element.type == EvidenceType.rearCamera)
              Container(
                width: 200,
                child: TextField(
                  controller: TextEditingController(text: element.assetID),
                  decoration: InputDecoration(hintText: "Asset ID"),
                  onChanged: (String newValue) {
                    setState(() {
                      element.assetID = newValue;
                    });
                  },
                ),
              ),
            if (element.type == EvidenceType.heartbeat)
              Container(
                width: 200,
                child: TextField(
                  controller: TextEditingController(
                      text: element.numberValue.toString()),
                  decoration: InputDecoration(hintText: "Heartbeat"),
                  onChanged: (String newValue) {
                    setState(() {
                      element.numberValue =
                          newValue.isEmpty ? 0 : int.parse(newValue);
                    });
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
