import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:json2yaml/json2yaml.dart';

enum EditorView { Elements, Cases, Characters, Cinematics }

class StoryEditor extends StatefulWidget {
  final Maestro maestro;
  final StoryEngine story;
  StoryEditor({required this.story, required this.maestro});

  @override
  _StoryEditorState createState() => _StoryEditorState();
}

class _StoryEditorState extends State<StoryEditor> {
  EvidenceType dropdownValue = EvidenceType.position;
  CharacterEngine? selectedCharacter;
  int selectedWeek = 1;
  int selectedDay = 1;
  List<CharacterEngine> characters = [];
  List<ElementEngine> filteredElements = [];
  List<int> weeks = List<int>.generate(10, (index) => index + 1);
  List<int> days = List<int>.generate(7, (index) => index + 1);
  EditorView selectedView = EditorView.Elements;

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
            child: selectedView == EditorView.Elements
                ? buildElementList()
                : selectedView == EditorView.Cases
                    ? buildCasesList()
                    : selectedView == EditorView.Characters
                        ? buildCharactersList()
                        : buildCinematicsList(),
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
          DropdownButton<EditorView>(
            value: selectedView,
            items: EditorView.values.map((EditorView view) {
              return DropdownMenuItem<EditorView>(
                value: view,
                child: Text(view.toString().split('.').last),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedView = value ?? EditorView.Elements;
              });
            },
          ),
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
          ElevatedButton(
              child: Text('Check'),
              onPressed: () async {
                var integrity = await Maestro.checkIntegrity(widget.story);
                for (var error in integrity) {
                  print(error.elementID + " " + error.reason);
                }
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
                        "WEEK-${element.week}-${element.day}-${element.hour}-${element.characterID}-${element.type.name}-${element.nsfwLevel}";
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
                        "WEEK-${element.week}-${element.day}-${element.hour}-${element.characterID}-${element.type.name}-${element.nsfwLevel}";
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
                          "WEEK-${element.week}-${element.day}-${element.hour}-${element.characterID}-${element.type.name}-${element.nsfwLevel}";
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
                    element.assetID = newValue;
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
                    element.numberValue =
                        newValue.isEmpty ? 0 : int.parse(newValue);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget buildCasesList() {
    List<CaseEngine> cases = widget.story.cases
        .where((c) => c.week == selectedWeek)
        .toList();

    return ListView(
      children: <Widget>[
        ...cases.map((c) => buildCaseTile(c)).toList(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
            child: Text('Add Case'),
            onPressed: () {
              setState(() {
                widget.story.cases.add(CaseEngine('', widget.story.characters[0].ID, "", '', 1));
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildCaseTile(CaseEngine caseEngine) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            DropdownButton<CharacterEngine>(
              value: characters.firstWhere(
                (character) => character.ID == caseEngine.characterID,
              ),
              items: characters.map((CharacterEngine character) {
                return DropdownMenuItem(
                  value: character,
                  child: Text(character.name),
                );
              }).toList(),
              onChanged: (CharacterEngine? newValue) {
                setState(() {
                  if (newValue != null) {
                    caseEngine.characterID = newValue.ID;
                  }
                });
              },
            ),
            DropdownButton<int>(
              value: caseEngine.week,
              items: weeks.map((int week) {
                return DropdownMenuItem(
                  value: week,
                  child: Text(week.toString()),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  if (newValue != null) {
                    caseEngine.week = newValue;
                  }
                });
              },
            ),
            Expanded(
              child: TextField(
                controller: TextEditingController(text: caseEngine.name),
                decoration: InputDecoration(hintText: "Case Name"),
                onChanged: (String newValue) {
                  caseEngine.name = newValue;
                },
              ),
            ),
            Expanded(
              child: TextField(
                controller: TextEditingController(text: caseEngine.description),
                decoration: InputDecoration(hintText: "Case Description"),
                onChanged: (String newValue) {
                  caseEngine.description = newValue;
                },
              ),
            ),
          ],
        ),
        Container(
          child: caseEngine.resolution != null
              ? buildCinematic(caseEngine.resolution!)
              : Container(),
        ),
        caseEngine.resolution != null
            ? Container()
            : ElevatedButton(
                child: Text('Add Cinematic'),
                onPressed: () {
                  setState(() {
                    caseEngine.resolution = CinematicEngine(
                        '', '', caseEngine.week, 1, 7, [],
                        nsfwLevel: 0);
                  });
                },
              ),
      ],
    );
  }

  Widget buildCharactersList() {
    // Add functionality to display characters
    return Container();
  }

  Widget buildCinematicsList() {
    List<CinematicEngine> filteredCinematics =
        widget.story.cinematics.where((cinematic) {
      return cinematic.week == selectedWeek && cinematic.day == selectedDay;
    }).toList();

    return ListView(
      children: <Widget>[
        ...filteredCinematics
            .map((cinematic) => buildCinematic(cinematic))
            .toList(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
            child: Text('Add Cinematic'),
            onPressed: () {
              setState(() {
                widget.story.cinematics.add(CinematicEngine(
                    '', '', selectedWeek, selectedDay, 7, [],
                    nsfwLevel: 0));
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildCinematic(CinematicEngine cinematic) {
    List<int> hours = [7, 10, 13, 16, 19, 22];
    List<int> nsfwLevels = [0, 1, 2];

    return ExpansionTile(
      title: Text(cinematic.ID),
      children: [
        Row(
          children: [
            DropdownButton<int>(
              value: cinematic.hour,
              items: hours.map((int hour) {
                return DropdownMenuItem<int>(
                  value: hour,
                  child: Text(hour.toString()),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  if (newValue != null) {
                    cinematic.hour = newValue;
                  }
                });
              },
            ),
            DropdownButton<int>(
              value: cinematic.nsfwLevel,
              items: nsfwLevels.map((int level) {
                return DropdownMenuItem<int>(
                  value: level,
                  child: Text(level.toString()),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  if (newValue != null) {
                    cinematic.nsfwLevel = newValue;
                  }
                });
              },
            ),
            ElevatedButton(
                onPressed: () {
                  widget.maestro
                      .goTo(cinematic.week, cinematic.day, cinematic.hour);
                },
                child: Text("Preview"))
          ],
        ),
        ...cinematic.sequences
            .map((sequence) => buildSequence(sequence))
            .toList(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
            child: Text('Add Sequence'),
            onPressed: () {
              setState(() {
                cinematic.sequences.add(CinematicSequenceEngine('', []));
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildSequence(CinematicSequenceEngine sequence) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller:
                      TextEditingController(text: sequence.cinematicAsset),
                  decoration: InputDecoration(hintText: "Asset ID"),
                  onChanged: (value) {
                    sequence.cinematicAsset = value;
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    final cinematic = widget.story.cinematics
                        .firstWhere((c) => c.sequences.contains(sequence));
                    cinematic.sequences.remove(sequence);
                  });
                },
              ),
            ],
          ),
          ...sequence.cinematicConversations
              .map((conversation) => buildConversation(conversation))
              .toList(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              child: Text('Add Conversation'),
              onPressed: () {
                setState(() {
                  sequence.cinematicConversations
                      .add(CinematicConversationEngine('', ''));
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildConversation(CinematicConversationEngine conversation) {
    return Row(
      children: <Widget>[
        Container(
          width: 200,
          child: TextField(
            controller: TextEditingController(text: conversation.character),
            decoration: InputDecoration(hintText: "Character"),
            onChanged: (value) {
              conversation.character = value;
            },
          ),
        ),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: conversation.text),
            decoration: InputDecoration(hintText: "Conversation Text"),
            onChanged: (value) {
              conversation.text = value;
            },
          ),
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            setState(() {
              final cinematic = widget.story.cinematics.firstWhere((c) {
                final sequence = c.sequences.firstWhere(
                    (s) => s.cinematicConversations.contains(conversation));
                return sequence != null;
              });
              final sequence = cinematic?.sequences.firstWhere(
                  (s) => s.cinematicConversations.contains(conversation));
              sequence?.cinematicConversations.remove(conversation);
            });
          },
        ),
      ],
    );
  }
}
