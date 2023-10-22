import 'package:flutter/material.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:hacking_game_ui/utils/game_date.dart';
import 'package:uuid/uuid.dart';

class StoryEditorConversationWidget extends StatefulWidget {
  final StoryEngine story;
  final Maestro maestro;

  const StoryEditorConversationWidget(this.story, this.maestro, {super.key});

  @override
  _StoryEditorConversationWidgetState createState() =>
      _StoryEditorConversationWidgetState();
}

class _StoryEditorConversationWidgetState
    extends State<StoryEditorConversationWidget> {
  List<int> days = List<int>.generate(7, (int index) => index + 1);
  List<int> weeks = List<int>.generate(10, (int index) => index + 1);
  List<int> hours = [7, 10, 13, 16, 19, 22];
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ...widget.story.conversations
            .map((conversation) => buildConversationTile(conversation))
            .toList(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ElevatedButton(
            child: const Text('Add Conversation'),
            onPressed: () {
              setState(() {
                widget.story.conversations.add(ConversationEngine(
                    const Uuid().v4(),
                    widget.story.characters[0].ID,
                    1,
                    1,
                    7, []));
              });
            },
          ),
        ),
      ],
    );
  }

  Widget buildConversationTile(ConversationEngine conversation) {
    return ExpansionTile(
      title: Text("${widget.story.characters.firstWhere(
            (character) => character.ID == conversation.characterID,
          ).name} W${conversation.week} ${getDayOfWeek(conversation.day)} ${conversation.hour}:00"),
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            DropdownButton<CharacterEngine>(
              value: widget.story.characters.firstWhere(
                (character) => character.ID == conversation.characterID,
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
                    conversation.characterID = newValue.ID;
                  }
                });
              },
            ),
            DropdownButton<int>(
              value: conversation.day,
              items: days.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  if (newValue != null) {
                    conversation.day = newValue;
                  }
                });
              },
            ),
            DropdownButton<int>(
              value: conversation.week,
              items: weeks.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  if (newValue != null) {
                    conversation.week = newValue;
                  }
                });
              },
            ),
            DropdownButton<int>(
              value: conversation.hour,
              items: hours.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  if (newValue != null) {
                    conversation.hour = newValue;
                  }
                });
              },
            ),
            Flexible(
              child: CheckboxListTile(
                title: const Text('Is Name Revealed'),
                value: conversation.isNameRevealed,
                onChanged: (bool? value) {
                  setState(() {
                    conversation.isNameRevealed = value ?? false;
                  });
                },
              ),
            ),
          ],
        ),
        Column(
          children: conversation.conversation
              .map<Widget>((bubble) => buildBubble(bubble))
              .toList(),
        ),
        Row(
          children: [
            ElevatedButton(
              child: const Text('Add Bubble'),
              onPressed: () {
                setState(() {
                  conversation.conversation.add(
                      ConversationBubbleDataEngine(Uuid().v4(), false, ''));
                });
              },
            ),
            ElevatedButton(
              child: const Text('Add File'),
              onPressed: () {
                setState(() {
                  conversation.conversation.add(
                      ConversationBubbleDataEngine(Uuid().v4(), false, '', type: ConversationBubbleDataEngineType.image));
                });
              },
            ),
            ElevatedButton(
              child: const Text('Add Payment'),
              onPressed: () {
                setState(() {
                  conversation.conversation.add(
                      ConversationBubbleDataEngine(Uuid().v4(), false, '', type: ConversationBubbleDataEngineType.bank));
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget buildBubble(ConversationBubbleDataEngine bubble) {
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
        const SizedBox(width: 10),
        Text(bubble.type.name),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: bubble.content),
            decoration: const InputDecoration(hintText: "Bubble Content"),
            onChanged: (String newValue) {
              bubble.content = newValue;
            },
          ),
        )
      ],
    );
  }
}
