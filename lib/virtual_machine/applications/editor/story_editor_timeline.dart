import 'package:flutter/material.dart';
import 'package:hacking_game_ui/engine/model_engine.dart';
import 'package:hacking_game_ui/maestro/maestro.dart';
import 'package:uuid/uuid.dart';

class StoryEditorTimelineWidget extends StatefulWidget {
  final StoryEngine story;
  final Maestro maestro;

  const StoryEditorTimelineWidget(this.story, this.maestro, {super.key});

  @override
  _StoryEditorTimelineWidgetState createState() =>
      _StoryEditorTimelineWidgetState();
}

class _StoryEditorTimelineWidgetState extends State<StoryEditorTimelineWidget> {
  final List<bool> _weekExpandedList = List.filled(10, false);
  List<TimeLine> _timeLines = [];

  @override
  void initState() {
    super.initState();
    _timeLines = widget.maestro.createTimeLines(widget.story);
    // Initialize expansion status for each week
    for (var timeline in _timeLines) {
      _weekExpandedList[timeline.week - 1] =
          true; // Assume all weeks should be expanded
    }
  }

  @override
  void didUpdateWidget(StoryEditorTimelineWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _timeLines = widget.maestro.createTimeLines(widget.story);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 10, // For 10 weeks
        itemBuilder: (BuildContext context, int weekIndex) {
          return Card(
            child: ExpansionTile(
              initiallyExpanded: _weekExpandedList[weekIndex],
              title: Text('Semaine ${weekIndex + 1}'),
              children: List.generate(7, (dayIndex) {
                return _buildDayTile(weekIndex + 1, dayIndex + 1);
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayTile(int week, int day) {
    // Collect all timeLines for specified week and day
    List<TimeLine> dayTimeLines =
        _timeLines.where((t) => t.week == week && t.day == day).toList();

    if (dayTimeLines.isEmpty) {
      // If no timelines found for the day, don't make it expandable
      return ListTile(
        title: Text('Jour $day'),
        contentPadding: EdgeInsets.only(left: 32.0),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {

              },
            ),
            IconButton(
              icon: Icon(Icons.movie_creation_outlined),
              onPressed: () {
                addCinematic(week, day);
              },
            ),
            IconButton(
              icon: Icon(Icons.chat_bubble_outline),
              onPressed: () {
                // logic to add new conversation
              },
            ),
          ],
        ),
      );
    }

    return ExpansionTile(
      title: Text('Jour $day'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.movie_creation_outlined),
            onPressed: () {
              addCinematic(week, day);
            },
          ),
          IconButton(
            icon: Icon(Icons.chat_bubble_outline),
            onPressed: () {
              // logic to add new conversation
            },
          ),
        ],
      ),
      children: dayTimeLines.map((timeLine) {
        return ListTile(
          title: Text('${timeLine.hour}:00'),
          contentPadding: EdgeInsets.only(left: 64.0),
          subtitle: _buildHourContent(timeLine),
        );
      }).toList(),
    );
  }

  void addCinematic(int week, int day) {
    setState(() {
      var uid = const Uuid().v4();
      widget.story.cinematics.add(CinematicEngine(uid, uid, week, day, 7, []));
      _timeLines = widget.maestro.createTimeLines(widget.story);
    });
  }

  Widget _buildHourContent(TimeLine timeLine) {
    List<Widget> contentCards = [];

    // Helper to build a card for elements, cinematics, and conversations
    Widget buildCard(
        {required String title,
        required Icon leading,
        required String subtitle,
        required VoidCallback onEdit,
        required VoidCallback onDelete}) {
      return Card(
        // Each Card widget now has two IconButtons for edit and delete
        child: ListTile(
          leading: leading,
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: onEdit,
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      );
    }

    // Add a card for each element
    contentCards.addAll(timeLine.elements.map((element) {
      return buildCard(
        title: element.description,
        leading: Icon(Icons.description),
        subtitle: 'Element',
        onEdit: () {
          _editElement(context, element);
        },
        onDelete: () async {
          bool? wantDelete = await _showConfirmationDialog(
            context,
            'Supprimer l\'élément',
            'Êtes-vous sûr de vouloir supprimer cet élément ?',
          );
          if (wantDelete ?? false) {
            // Insert logic to delete the element
          }
        },
      );
    }));

    // Add a card for each cinematic
    contentCards.addAll(timeLine.cinematics.map((cinematic) {
      return buildCard(
        title: cinematic.name,
        leading: Icon(Icons.movie),
        subtitle: 'Cinematique',
        onEdit: () {
          // Insert logic to edit the cinematic
        },
        onDelete: () async {
          bool? wantDelete = await _showConfirmationDialog(
            context,
            'Supprimer la cinématique',
            'Êtes-vous sûr de vouloir supprimer cette cinématique ?',
          );
          if (wantDelete ?? false) {
            // Insert logic to delete the cinematic
          }
        },
      );
    }));

    // Add a card for each conversation
    contentCards.addAll(timeLine.conversations.map((conversation) {
      return buildCard(
        title: 'Conversation',
        leading: Icon(Icons.chat),
        subtitle:
            'ID: ${conversation.conversationID}', // Assuming a property ID in ConversationEngine
        onEdit: () {
          // Insert logic to edit the conversation
        },
        onDelete: () async {
          bool? wantDelete = await _showConfirmationDialog(
            context,
            'Supprimer la conversation',
            'Êtes-vous sûr de vouloir supprimer cette conversation ?',
          );
          if (wantDelete ?? false) {
            // Insert logic to delete the conversation
          }
        },
      );
    }));

    return Column(children: contentCards);
  }

  Future<bool?> _showConfirmationDialog(
      BuildContext context, String title, String content) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: Text('Annuler'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Supprimer'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  Future<void> _editElement(BuildContext context, ElementEngine element) async {
    // Prepare text editing controllers for each field that will be editable in the dialog
    TextEditingController _descriptionController =
        TextEditingController(text: element.description);
    TextEditingController _weekController =
        TextEditingController(text: element.week.toString());
    TextEditingController _dayController =
        TextEditingController(text: element.day.toString());
    TextEditingController _hourController =
        TextEditingController(text: element.hour.toString());
    String? _selectedType = element.type
        .toString(); // Should be adjusted based on how the types are handled

    // Present the edit dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier l\'élément'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(
                  controller: _weekController,
                  decoration: InputDecoration(labelText: 'Semaine'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _dayController,
                  decoration: InputDecoration(labelText: 'Jour'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _hourController,
                  decoration: InputDecoration(labelText: 'Heure'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButton<String>(
                  value: _selectedType,
                  items: EvidenceType.values.map((EvidenceType type) {
                    return DropdownMenuItem<String>(
                      value: type.toString(),
                      child: Text(type.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                CheckboxListTile(
                  value: element.isEvidence,
                  title: Text('Est une preuve ?'),
                  onChanged: (bool? value) {
                    setState(() {
                      element.isEvidence = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  value: element.isOptionalEvidence,
                  title: Text('Est une preuve optionnelle ?'),
                  onChanged: (bool? value) {
                    setState(() {
                      element.isOptionalEvidence = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Enregistrer'),
              onPressed: () {
                setState(() {
                  // Update the element with the new values
                  element.week = int.parse(_weekController.text);
                  element.day = int.parse(_dayController.text);
                  element.hour = int.parse(_hourController.text);
                  element.type = EvidenceType.values
                      .firstWhere((type) => type.toString() == _selectedType);
                  element.description = _descriptionController.text;
                  // Here you may need to add logic to save the updated element to a server or local database
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    // Dispose of text editing controllers after the dialog is closed
    _descriptionController.dispose();
    _weekController.dispose();
    _dayController.dispose();
    _hourController.dispose();
  }
}
