import 'package:flutter/material.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:uuid/uuid.dart';

class StoryEditorCharactersWidget extends StatefulWidget {
  final StoryEngine story;
  final Maestro maestro;

  const StoryEditorCharactersWidget(this.story, this.maestro, {super.key});

  @override
  _StoryEditorCharactersWidgetState createState() =>
      _StoryEditorCharactersWidgetState();
}

class _StoryEditorCharactersWidgetState
    extends State<StoryEditorCharactersWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ...widget.story.characters
            .map((character) => buildCharacterTile(character))
            .toList(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
            child: const Text('Add Character'),
            onPressed: () {
              setState(() {
                widget.story.characters.add(CharacterEngine(
                    const Uuid().v4(), 'New Character', 1, '', '',
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
      padding: const EdgeInsets.all(10.0),
      child: Card(
        child: Column(
          children: <Widget>[
            TextField(
              controller: TextEditingController(text: character.name),
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (newValue) {
                character.name = newValue;
              },
            ),
            TextField(
              controller: TextEditingController(text: character.avatar),
              decoration: const InputDecoration(labelText: 'Avatar'),
              onChanged: (newValue) {
                character.avatar = newValue;
              },
            ),
            TextField(
              controller: TextEditingController(text: character.wallpaper),
              decoration: const InputDecoration(labelText: 'Wallpaper'),
              onChanged: (newValue) {
                character.wallpaper = newValue;
              },
            ),
            TextField(
              controller: TextEditingController(text: character.unrevealedName),
              decoration: const InputDecoration(labelText: 'Unrevealed Name'),
              onChanged: (newValue) {
                character.unrevealedName = newValue;
              },
            ),
            CheckboxListTile(
              title: const Text('Is Playable'),
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
