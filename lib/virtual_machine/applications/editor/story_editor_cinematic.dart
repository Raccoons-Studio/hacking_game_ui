import 'package:flutter/material.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';

class StoryEditorCinematicsWidget extends StatefulWidget {
  final StoryEngine story;
  final Maestro maestro;
  final List<CinematicEngine> cinematics;
  
  StoryEditorCinematicsWidget(this.story, this.maestro, this.cinematics);
  
  @override 
  _StoryEditorCinematicsWidgetState createState() => _StoryEditorCinematicsWidgetState();
  
}

class _StoryEditorCinematicsWidgetState extends State<StoryEditorCinematicsWidget>{
  
  Widget build (BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        ...widget.cinematics
            .map((cinematic) => buildCinematic(cinematic))
            .toList(),
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

class StoryEditorCharactersWidget extends StatefulWidget {

  @override 
  _StoryEditorCharactersWidgetState createState() => _StoryEditorCharactersWidgetState();
  
}

class _StoryEditorCharactersWidgetState extends State<StoryEditorCharactersWidget>{

  Widget build (BuildContext context) {
    // define your character list widget here.
    return Container();
  }
}