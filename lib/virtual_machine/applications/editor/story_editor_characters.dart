import 'package:flutter/material.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:uuid/uuid.dart';

class StoryEditorCharactersWidget extends StatefulWidget {
  final StoryEngine story;
  final Maestro maestro;

  StoryEditorCharactersWidget(this.story, this.maestro);

  @override
  _StoryEditorCharactersWidgetState createState() =>
      _StoryEditorCharactersWidgetState();
}

class _StoryEditorCharactersWidgetState
    extends State<StoryEditorCharactersWidget> {
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ...widget.story.characters
            .map((character) => buildCharacterTile(character))
            .toList(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
            child: Text('Add Character'),
            onPressed: () {
              setState(() {
                widget.story.characters.add(CharacterEngine(
                    Uuid().v4(), 'New Character', 1, '', '',
                    isPlayable: false, unrevealedName: ''));
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildCharacterTile(CharacterEngine character) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Card(
        child: Column(
          children: <Widget>[
            TextField(
              controller: TextEditingController(text: character.name),
              decoration: InputDecoration(labelText: 'Name'),
              onChanged: (newValue) {
                character.name = newValue;
              },
            ),
            TextField(
              controller: TextEditingController(text: character.avatar),
              decoration: InputDecoration(labelText: 'Avatar'),
              onChanged: (newValue) {
                character.avatar = newValue;
              },
            ),
            TextField(
              controller: TextEditingController(text: character.wallpaper),
              decoration: InputDecoration(labelText: 'Wallpaper'),
              onChanged: (newValue) {
                character.wallpaper = newValue;
              },
            ),
            TextField(
              controller: TextEditingController(text: character.unrevealedName),
              decoration: InputDecoration(labelText: 'Unrevealed Name'),
              onChanged: (newValue) {
                character.unrevealedName = newValue;
              },
            ),
            CheckboxListTile(
              title: Text('Is Playable'),
              value: character.isPlayable,
              onChanged: (newValue) {
                setState(() {
                  character.isPlayable = newValue ?? false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
