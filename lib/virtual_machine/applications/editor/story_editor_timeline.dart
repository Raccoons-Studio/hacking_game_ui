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
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.movie_creation_outlined),
              onPressed: () {
                var cinematic = addCinematic(week, day);
                _editCinematic(context, cinematic);
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

  CinematicEngine addCinematic(int week, int day) {
    var uid = const Uuid().v4();
    var cinematic = CinematicEngine(uid, uid, week, day, 7, []);
    widget.story.cinematics.add(cinematic);
    setState(() {
      _timeLines = widget.maestro.createTimeLines(widget.story);
    });
    return cinematic;
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
        subtitle:
            "${widget.story.characters.firstWhere((character) => character.ID == element.characterID).name} - ${element.type.toString().split('.').last}",
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
        title: "${cinematic.name} - ${cinematic.description}",
        leading: Icon(Icons.movie),
        subtitle: 'Cinematique',
        onEdit: () {
          _editCinematic(context, cinematic);
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
        subtitle: widget.story.characters
            .firstWhere((character) => character.ID == conversation.characterID)
            .name, // Assuming a property ID in ConversationEngine
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

  Future<void> _editCinematic(
      BuildContext context, CinematicEngine cinematic) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(0),
          child: _buildCinematicEditDialog(context, cinematic),
        );
      },
    );
  }

  Widget _buildCinematicEditDialog(
      BuildContext context, CinematicEngine cinematic) {
    TextEditingController _descriptionController =
        TextEditingController(text: cinematic.description);
    TextEditingController _weekController =
        TextEditingController(text: cinematic.week.toString());
    TextEditingController _dayController =
        TextEditingController(text: cinematic.day.toString());

    return StatefulBuilder(
      builder: (context, setState) {
        return Scaffold(
          appBar: _buildAppBar(context, cinematic, _weekController,
              _dayController, _descriptionController),
          body: _buildDialogContent(
              context, setState, cinematic, _descriptionController),
        );
      },
    );
  }

  AppBar _buildAppBar(
      BuildContext context,
      CinematicEngine cinematic,
      TextEditingController weekController,
      TextEditingController dayController,
      TextEditingController descriptionController) {
    return AppBar(
      title: Text('Modifier la cinématique'),
      actions: [
        TextButton(
          onPressed: () => _saveCinematic(context, cinematic, weekController,
              dayController, descriptionController),
          child: Text('Enregistrer', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _saveCinematic(
      BuildContext context,
      CinematicEngine cinematic,
      TextEditingController weekController,
      TextEditingController dayController,
      TextEditingController descriptionController) {
    cinematic.week = int.parse(weekController.text);
    cinematic.day = int.parse(dayController.text);
    cinematic.description = descriptionController.text;
    // Additional save logic as needed
    Navigator.of(context).pop();
  }

  SingleChildScrollView _buildDialogContent(
    BuildContext context,
    void Function(void Function()) setState,
    CinematicEngine cinematic,
    TextEditingController descriptionController,
  ) {
    List<int> hours = [7, 10, 13, 16, 19, 22];
    List<int> nsfwLevels = [0, 1, 2];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildNumberTextField('Semaine', cinematic.week.toString(),
              (newValue) {
            cinematic.week = int.parse(newValue);
          }),
          _buildNumberTextField('Jour', cinematic.day.toString(), (newValue) {
            cinematic.day = int.parse(newValue);
          }),
          _buildDropdownField('Heure', hours, cinematic.hour, (newValue) {
            cinematic.hour = newValue;
          }),
          _buildDropdownField('Niveau NSFW', nsfwLevels, cinematic.nsfwLevel,
              (newValue) {
            cinematic.nsfwLevel = newValue;
          }),
          _buildTextField(descriptionController, 'Description', (newValue) {
            cinematic.description = newValue;
          }),
          ...cinematic.sequences
              .map((sequence) =>
                  _buildSequenceEditor(context, setState, cinematic, sequence))
              .toList(),
          _buildAddSequenceButton(setState, cinematic),
        ],
      ),
    );
  }

  Widget _buildNumberTextField(
      String label, String value, Function(String) onChanged) {
    TextEditingController controller = TextEditingController(text: value);
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      Function(String) onChanged) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownField<T>(
    String label,
    List<T> items,
    T selectedValue,
    Function(T) onChanged,
  ) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(labelText: label),
      value: selectedValue,
      items: items.map((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
      onChanged: (T? newValue) {
        if (newValue != null) onChanged(newValue);
      },
    );
  }

  Widget _buildSequenceEditor(
    BuildContext context,
    void Function(void Function()) setState,
    CinematicEngine cinematic,
    CinematicSequenceEngine sequence,
  ) {
    TextEditingController sequenceAssetController =
        TextEditingController(text: sequence.cinematicAsset);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(sequence.cinematicAsset,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  cinematic.sequences.remove(sequence);
                });
              },
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: TextField(
            controller: sequenceAssetController,
            decoration: InputDecoration(hintText: 'Asset ID'),
            onChanged: (value) => sequence.cinematicAsset = value,
          ),
        ),
        ...sequence.cinematicConversations
            .map((conversation) => _buildConversationEditor(
                context, setState, cinematic, sequence, conversation))
            .toList(),
        Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: _buildAddConversationButton(setState, sequence),
        ),
      ],
    );
  }

  Widget _buildConversationEditor(
    BuildContext context,
    void Function(void Function()) setState,
    CinematicEngine cinematic,
    CinematicSequenceEngine sequence,
    CinematicConversationEngine conversation,
  ) {
    TextEditingController characterController =
        TextEditingController(text: conversation.character);
    TextEditingController textController =
        TextEditingController(text: conversation.text);
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: TextField(
              controller: characterController,
              decoration: InputDecoration(hintText: 'Character'),
              onChanged: (value) => conversation.character = value,
            ),
          ),
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(hintText: 'Text'),
              onChanged: (value) => conversation.text = value,
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                sequence.cinematicConversations.remove(conversation);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddSequenceButton(
      void Function(void Function()) setState, CinematicEngine cinematic) {
    return ElevatedButton(
      child: Text('Add Sequence'),
      onPressed: () {
        setState(() {
          cinematic.sequences.add(CinematicSequenceEngine('', []));
        });
      },
    );
  }

  Widget _buildAddConversationButton(void Function(void Function()) setState,
      CinematicSequenceEngine sequence) {
    return ElevatedButton(
      child: Text('Add Conversation'),
      onPressed: () {
        setState(() {
          sequence.cinematicConversations
              .add(CinematicConversationEngine('', ''));
        });
      },
    );
  }
}
