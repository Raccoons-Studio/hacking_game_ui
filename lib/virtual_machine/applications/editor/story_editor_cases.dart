import 'package:flutter/material.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/virtual_machine/applications/editor/story_editor.dart';
import 'package:hacking_game_ui/virtual_machine/applications/editor/story_editor_cinematic.dart';
import 'package:uuid/uuid.dart';

class StoryEditorCasesWidget extends StatefulWidget {
  final StoryEngine story;
  final Maestro maestro;

  StoryEditorCasesWidget(this.story, this.maestro);

  @override
  _StoryEditorCasesWidgetState createState() => _StoryEditorCasesWidgetState();
}

class _StoryEditorCasesWidgetState extends State<StoryEditorCasesWidget> {
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ...widget.story.cases.map((c) => buildCaseTile(c)).toList(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
            child: Text('Add Case'),
            onPressed: () {
              setState(() {
                var cinematicID = Uuid().v4();
                widget.story.cases.add(CaseEngine(
                    Uuid().v4(), widget.story.characters[0].ID, "", '', 1,
                    resolution: CinematicEngine(cinematicID, cinematicID, 1, 1, 7, []),
                    blackmail: ConversationEngine(Uuid().v4(), '', 1, 1, 7, [])));
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
              value: widget.story.characters.firstWhere(
                (character) => character.ID == caseEngine.characterID,
              ),
              items: widget.story.characters.map((CharacterEngine character) {
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
        Text("Cinematic at the resolution"),
        Container(
          child: caseEngine.resolution != null
              ? StoryEditorCinematicsWidget(widget.story, widget.maestro,
                  List<CinematicEngine>.from([caseEngine.resolution!]))
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
        ExpansionTile(
          title: Text("Blackmail conversation"),
          children: [caseEngine.blackmail != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                        buildConversationHeader(),
                      ] +
                      caseEngine.blackmail!.conversation
                          .map<Widget>((c) =>
                              buildConversationBubble(c, caseEngine.blackmail!))
                          .toList(),
                )
              : Container()],
        ),
        caseEngine.blackmail != null
            ? ElevatedButton(
                child: Text('Add Conversation Bubble'),
                onPressed: () {
                  setState(() {
                    caseEngine.blackmail!.conversation
                        .add(ConversationBubbleDataEngine(false, ''));
                  });
                },
              )
            : Container(),
      ],
    );
  }

  Widget buildConversationHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          'Player ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          'Conversation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget buildConversationBubble(ConversationBubbleDataEngine bubble,
      ConversationEngine conversationEngine) {
    return Row(
      children: <Widget>[
        Checkbox(
          value: bubble.isPlayer,
          onChanged: (bool? newValue) {
            setState(() {
              if (newValue != null) {
                bubble.isPlayer = newValue;
              }
            });
          },
        ),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: bubble.content),
            decoration: InputDecoration(hintText: "Bubble Content"),
            onChanged: (String newValue) {
              bubble.content = newValue;
            },
          ),
        ),
      ],
    );
  }
}
