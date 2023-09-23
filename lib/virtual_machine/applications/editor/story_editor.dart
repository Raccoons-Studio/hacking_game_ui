import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/virtual_machine/applications/editor/story_editor_cases.dart';
import 'package:hacking_game_ui/virtual_machine/applications/editor/story_editor_cinematic.dart';
import 'package:hacking_game_ui/virtual_machine/applications/editor/story_editor_elements.dart';
import 'package:hacking_game_ui/virtual_machine/applications/editor/story_editor_filters.dart';
import 'package:hacking_game_ui/virtual_machine/applications/editor/story_utils.dart';

enum EditorView { Elements, Cases, Characters, Cinematics }

List<int> weeks = List<int>.generate(10, (index) => index + 1);
List<int> days = List<int>.generate(7, (index) => index + 1);

class StoryEditor extends StatefulWidget {
  final Maestro maestro;
  final StoryEngine story;
  StoryEditor({required this.story, required this.maestro});

  @override
  _StoryEditorState createState() => _StoryEditorState();
}

class _StoryEditorState extends State<StoryEditor> {
  EvidenceType dropdownValue = EvidenceType.position;
  List<CharacterEngine> characters = [];
  List<ElementEngine> filteredElements = [];
  int selectedWeek = 1;
  int selectedDay = 1;
  EditorView selectedView = EditorView.Elements;
  CharacterEngine? selectedCharacter;

  Future<List<CharacterEngine>> getAllCharacters() async {
    characters = widget.story.characters;
    if (characters.isNotEmpty && !selectedCharacter.isNull)
      selectedCharacter = characters[0];
    setState(() {});
    return characters;
  }

  void filterElements(EditorView selectedView, String characterID,
      int selectedWeek, int selectedDay) {
    if (characterID != "") {
      filteredElements = widget.story.elements.where((element) {
        return element.characterID == characterID &&
            element.week == selectedWeek &&
            element.day == selectedDay;
      }).toList();
    }
    setState(() {
      if (characterID != "") {
        this.selectedCharacter =
            characters.firstWhere((character) => character.ID == characterID);
      }
      this.selectedDay = selectedDay;
      this.selectedView = selectedView;
      this.selectedWeek = selectedWeek;
      this.selectedView = selectedView;
    });
  }

  @override
  void initState() {
    super.initState();
    getAllCharacters();
    filterElements(selectedView, selectedCharacter?.ID ?? characters[0].ID,
        selectedWeek, selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          FutureBuilder<List<CharacterEngine>>(
              future: getAllCharacters(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                return StoryEditorFiltersWidget(
                    snapshot.data!, filterElements, saveStory, check);
              }),
          Expanded(
            child: selectedView == EditorView.Elements
                ? StoryEditorElementsWidget(widget.story, filteredElements)
                : selectedView == EditorView.Cases
                    ? StoryEditorCasesWidget(widget.story, widget.maestro)
                    : selectedView == EditorView.Characters
                        ? buildCharactersList()
                        : StoryEditorCinematicsWidget(widget.story, widget.maestro, widget.story.cinematics),
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
                filterElements(
                    selectedView,
                    selectedCharacter?.ID ?? characters[0].ID,
                    selectedWeek,
                    selectedDay);
              });
            },
          ),
        ],
      ),
    );
  }

  saveStory() {
    saveStoryToYaml(widget.story);
  }

  check() async {
    await Maestro.checkIntegrity(widget.story);
  }

  Widget buildCharactersList() {
    // Add functionality to display characters
    return Container();
  }

  

  

  
}
