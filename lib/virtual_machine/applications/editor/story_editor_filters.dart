import 'package:flutter/material.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/virtual_machine/applications/editor/story_editor.dart';

class StoryEditorFiltersWidget extends StatefulWidget {
  List<CharacterEngine> characters;
  Function(EditorView selectedView, String characterID, int selectedWeek, int selectedDay) filterElements;
  Function() saveStoryToYaml;
  Function() checkIntegrity;

  StoryEditorFiltersWidget(this.characters, this.filterElements, this.saveStoryToYaml, this.checkIntegrity);

  @override
  State<StoryEditorFiltersWidget> createState() => _StoryEditorFiltersWidgetState();
}

class _StoryEditorFiltersWidgetState extends State<StoryEditorFiltersWidget> {
  int selectedWeek = 1;
  int selectedDay = 1;
  EditorView selectedView = EditorView.Elements;
  CharacterEngine? selectedCharacter;

  @override
  void initState() {
    super.initState();
    if (widget.characters.isNotEmpty) {
      selectedCharacter = widget.characters.first;
    }
  }
  
  @override
  Widget build(BuildContext context) {
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
            items: widget.characters.map((character) {
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
                widget.filterElements(selectedView, selectedCharacter?.ID ?? '', selectedWeek, selectedDay);
              });
            },
          ),
          ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                widget.saveStoryToYaml();
              }),
          ElevatedButton(
              child: Text('Check'),
              onPressed: () async {
                var integrity = await widget.checkIntegrity();
                for (var error in integrity) {
                  print(error.elementID + " " + error.reason);
                }
              }),
        ],
      ),
    );
  }
}